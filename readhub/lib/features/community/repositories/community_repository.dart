import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment_model.dart';
import '../../profile/models/notification_model.dart';
import '../../profile/repositories/notification_repository.dart';

class CommunityRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationRepository _notificationRepo = NotificationRepository();

  // ── KOLEKSİYON REFERANSLARI ─────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> _commentsCol(String bookId) =>
      _db.collection('books').doc(bookId).collection('comments');

  CollectionReference<Map<String, dynamic>> _repliesCol(
          String bookId, String commentId) =>
      _commentsCol(bookId).doc(commentId).collection('replies');

  // ── STREAM: Gerçek zamanlı yorum akışı ───────────────────────────────────
  Stream<List<CommentModel>> commentsStream(String bookId, String chapterId) {
    return _commentsCol(bookId)
        .where('chapterId', isEqualTo: chapterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => CommentModel.fromFirestore(d)).toList());
  }

  // ── STREAM: Kullanıcının yorumlarını kendi koleksiyonundan getir (Index Gerekmez!) ──
  Stream<List<Map<String, dynamic>>> getUserCommentsStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('my_comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['id'] = d.id;
              return data;
            }).toList());
  }

  // ── STREAM: Gerçek zamanlı yanıt akışı ───────────────────────────────────
  Stream<List<CommentModel>> repliesStream(String bookId, String commentId) {
    return _repliesCol(bookId, commentId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => CommentModel.fromFirestore(d)).toList());
  }

  // ── YORUM EKLE ────────────────────────────────────────────────────────────
  Future<void> addComment({
    required String bookId,
    required String text,
    required bool isSpoiler,
    required String chapterId,
    required String bookTitle,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final username = user.displayName ?? user.email?.split('@').first ?? 'Kullanıcı';
    final initials = username.length >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();

    final ref = _commentsCol(bookId).doc();
    await ref.set({
      'userId': user.uid,
      'username': username,
      'avatarInitials': initials,
      'text': text.trim(),
      'isSpoiler': isSpoiler,
      'chapterId': chapterId,
      'likedByUserIds': [],
      'replyCount': 0,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Profi sayfasında hızlı görüntfileme için kullanıcının kendi koleksiyonuna kaydet
    await _db.collection('users').doc(user.uid).collection('my_comments').doc(ref.id).set({
      'bookId': bookId,
      'bookTitle': bookTitle,
      'text': text.trim(),
      'isSpoiler': isSpoiler,
      'chapterId': chapterId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── YANIT EKLE ────────────────────────────────────────────────────────────
  Future<void> addReply({
    required String bookId,
    required String parentCommentId,
    required String text,
    required bool isSpoiler,
    required String chapterId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final username = user.displayName ?? user.email?.split('@').first ?? 'Kullanıcı';
    final initials = username.length >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();

    // Yanıt belgesi ekle
    await _repliesCol(bookId, parentCommentId).add({
      'userId': user.uid,
      'username': username,
      'avatarInitials': initials,
      'text': text.trim(),
      'isSpoiler': isSpoiler,
      'chapterId': chapterId,
      'likedByUserIds': [],
      'replyCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Üst yorumun replyCount'ını güncelle ve bildirim gönder
    final parentCommentDoc = await _commentsCol(bookId).doc(parentCommentId).get();
    if (parentCommentDoc.exists) {
      final parentData = parentCommentDoc.data()!;
      final parentUserId = parentData['userId'] as String;
      
      // Eğer kendi yorumuna yanıt vermiyorsa bildirim gönder
      if (parentUserId != user.uid) {
        final bookDoc = await _db.collection('books').doc(bookId).get();
        final bookTitle = bookDoc.data()?['title'] ?? 'bir kitap';
        
        await _notificationRepo.sendNotification(
          parentUserId,
          NotificationModel(
            id: '', // Firestore add() will generate this
            type: NotificationType.reply,
            title: '$username yorumuna yanıt verdi',
            subtitle: '$bookTitle topluluğunda senin yorumuna yanıt gelindi.',
            bookId: bookId,
            createdAt: DateTime.now(),
          ),
        );
      }
      
      await _commentsCol(bookId).doc(parentCommentId).update({
        'replyCount': FieldValue.increment(1),
      });
    }
  }

  // ── YORUM BEĞENİ TOGGLE ───────────────────────────────────────────────────
  Future<void> toggleCommentLike({
    required String bookId,
    required String commentId,
    required bool currentlyLiked,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final ref = _commentsCol(bookId).doc(commentId);
    if (currentlyLiked) {
      await ref.update({'likedByUserIds': FieldValue.arrayRemove([uid])});
    } else {
      await ref.update({'likedByUserIds': FieldValue.arrayUnion([uid])});
      
      // Beğeni bildirimi gönder
      final commentDoc = await ref.get();
      if (commentDoc.exists) {
        final commentData = commentDoc.data()!;
        final targetUserId = commentData['userId'] as String;
        
        if (targetUserId != uid) {
          final user = FirebaseAuth.instance.currentUser;
          final username = user?.displayName ?? 'Birisi';
          final bookDoc = await _db.collection('books').doc(bookId).get();
          final bookTitle = bookDoc.data()?['title'] ?? 'bir kitap';

          await _notificationRepo.sendNotification(
            targetUserId,
            NotificationModel(
              id: '',
              type: NotificationType.like,
              title: '$username yorumunu beğendi',
              subtitle: '$bookTitle hakkındaki yorumun beğenildi.',
              bookId: bookId,
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    }
  }

  // ── YANIT BEĞENİ TOGGLE ───────────────────────────────────────────────────
  Future<void> toggleReplyLike({
    required String bookId,
    required String commentId,
    required String replyId,
    required bool currentlyLiked,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final ref = _repliesCol(bookId, commentId).doc(replyId);
    if (currentlyLiked) {
      await ref.update({'likedByUserIds': FieldValue.arrayRemove([uid])});
    } else {
      await ref.update({'likedByUserIds': FieldValue.arrayUnion([uid])});
    }
  }

  // ── YORUM SİL ──────────────────────────────────────────────────────────────
  Future<void> deleteComment({
    required String bookId,
    required String commentId,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Yorumun sahibi mi kontrol et
    final commentDoc = await _commentsCol(bookId).doc(commentId).get();
    if (!commentDoc.exists) return;
    if (commentDoc.data()?['userId'] != uid) return; // Başkasının yorumunu silemez

    // Batch ile hem kitap koleksiyonundan hem de kullanıcının my_comments'inden sil
    final batch = _db.batch();
    batch.delete(_commentsCol(bookId).doc(commentId));
    batch.delete(_db.collection('users').doc(uid).collection('my_comments').doc(commentId));
    await batch.commit();
  }

  // ── MEVCUT BÖLÜM ID'LERİNİ ÇEK ───────────────────────────────────────────
  Future<List<String>> getChapters(String bookId) async {
    // Statik liste — ileride dinamik yapılabilir
    return ['Genel', 'Bölüm 1', 'Bölüm 2', 'Bölüm 3', 'Son Değerlendirme'];
  }

  // ── SEED DATA: Boş kitaplar için örnek yorumlar ekle ─────────────────────
  Future<void> seedMockDataIfEmpty(String bookId) async {
    final existing = await _commentsCol(bookId).limit(1).get();
    if (existing.docs.isNotEmpty) return; // Zaten veri var

    final seeds = [
      {
        'userId': 'seed_alice',
        'username': 'Alice K.',
        'avatarInitials': 'AK',
        'text': 'Bu kitabın başlangıcı yavaş ilerliyor ama dünya kurgusu inanılmaz! İlk 50 sayfadan sonra kitabı bırakmak neredeyse imkânsız hâle geliyor.',
        'isSpoiler': false,
        'chapterId': 'Genel',
        'likedByUserIds': ['seed_bob', 'seed_charlie'],
        'replyCount': 1,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
      },
      {
        'userId': 'seed_bob',
        'username': 'Bora Y.',
        'avatarInitials': 'BY',
        'text': 'Ana karakterin gerçek kimliğini öğrendiğimizde inanılmaz bir his yaşadım. O ihanet sahnesi çok güçlüydü.',
        'isSpoiler': true,
        'chapterId': 'Genel',
        'likedByUserIds': ['seed_alice'],
        'replyCount': 0,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
      },
      {
        'userId': 'seed_charlie',
        'username': 'Cemre T.',
        'avatarInitials': 'CT',
        'text': 'İlk paragraftan itibaren büyülendi. Yazar dili kullanmada ustalaşmış, her cümle özenle seçilmiş.',
        'isSpoiler': false,
        'chapterId': 'Bölüm 1',
        'likedByUserIds': [],
        'replyCount': 0,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 18))),
      },
      {
        'userId': 'seed_dave',
        'username': 'Deniz A.',
        'avatarInitials': 'DA',
        'text': 'Kahramanın gizli kapıyı bulduğu sahne — gözlerimi kapayıp bir daha okudum. Film olsa izlerim!',
        'isSpoiler': true,
        'chapterId': 'Bölüm 1',
        'likedByUserIds': ['seed_alice'],
        'replyCount': 0,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
      },
      {
        'userId': 'seed_eve',
        'username': 'Elif S.',
        'avatarInitials': 'ES',
        'text': 'Bu bölümün temposu çok daha hızlı, neredeyse nefes almadan bitirdim!',
        'isSpoiler': false,
        'chapterId': 'Bölüm 2',
        'likedByUserIds': ['seed_bob', 'seed_charlie', 'seed_dave'],
        'replyCount': 0,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 1))),
      },
    ];

    final batch = _db.batch();
    for (final seed in seeds) {
      final ref = _commentsCol(bookId).doc();
      batch.set(ref, seed);
    }
    await batch.commit();

    // Alice'in ilk yorumuna bir yanıt ekle (seed_bob'dan)
    final aliceComment = await _commentsCol(bookId)
        .where('userId', isEqualTo: 'seed_alice')
        .limit(1)
        .get();
    if (aliceComment.docs.isNotEmpty) {
      await _repliesCol(bookId, aliceComment.docs.first.id).add({
        'userId': 'seed_bob',
        'username': 'Bora Y.',
        'avatarInitials': 'BY',
        'text': 'Kesinlikle katılıyorum! 50. sayfadan sonra kitabı elimden bırakamadım.',
        'isSpoiler': false,
        'chapterId': 'Genel',
        'likedByUserIds': [],
        'replyCount': 0,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2, hours: 22))),
      });
    }
  }
}
