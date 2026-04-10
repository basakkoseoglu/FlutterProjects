import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String userId;
  final String username;
  final String avatarInitials; // İlk 2 harf — profil resmi yerine
  final String text;
  final bool isSpoiler;
  final DateTime createdAt;
  final List<String> likedByUserIds; // Beğeni listesi (duplicate önler)
  final String chapterId; // 'Genel', 'Bölüm 1', etc.
  final int replyCount;
  final String? bookId;
  final String? bookTitle;
  final List<CommentModel> replies; // Yüklü yanıtlar (opsiyonel)

  CommentModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.avatarInitials,
    required this.text,
    required this.isSpoiler,
    required this.createdAt,
    required this.likedByUserIds,
    required this.chapterId,
    this.replyCount = 0,
    this.bookId,
    this.bookTitle,
    this.replies = const [],
  });

  int get likeCount => likedByUserIds.length;
  bool isLikedBy(String uid) => likedByUserIds.contains(uid);

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Attempt to extract bookId from path if not in data (e.g. for existing comments)
    // Path: books/{bookId}/comments/{commentId}
    String? pathBookId;
    try {
      final parts = doc.reference.path.split('/');
      if (parts.length >= 2 && parts[0] == 'books') {
        pathBookId = parts[1];
      }
    } catch (_) {}

    return CommentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Kullanıcı',
      avatarInitials: data['avatarInitials'] ?? '??',
      text: data['text'] ?? '',
      isSpoiler: data['isSpoiler'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likedByUserIds: List<String>.from(data['likedByUserIds'] ?? []),
      chapterId: data['chapterId'] ?? 'Genel',
      replyCount: (data['replyCount'] ?? 0) as int,
      bookId: data['bookId'] ?? pathBookId,
      bookTitle: data['bookTitle'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'avatarInitials': avatarInitials,
      'text': text,
      'isSpoiler': isSpoiler,
      'createdAt': FieldValue.serverTimestamp(),
      'likedByUserIds': likedByUserIds,
      'chapterId': chapterId,
      'replyCount': replyCount,
    };
  }

  /// Beğeni listesi güncellenmiş kopya
  CommentModel withToggledLike(String uid) {
    final updated = List<String>.from(likedByUserIds);
    if (updated.contains(uid)) {
      updated.remove(uid);
    } else {
      updated.add(uid);
    }
    return _copyWith(likedByUserIds: updated);
  }

  /// Yanıt listesi güncellenmiş kopya
  CommentModel withReplies(List<CommentModel> newReplies) {
    return _copyWith(replies: newReplies);
  }

  CommentModel _copyWith({
    List<String>? likedByUserIds,
    List<CommentModel>? replies,
    int? replyCount,
  }) {
    return CommentModel(
      id: id,
      userId: userId,
      username: username,
      avatarInitials: avatarInitials,
      text: text,
      isSpoiler: isSpoiler,
      createdAt: createdAt,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
      chapterId: chapterId,
      replyCount: replyCount ?? this.replyCount,
      replies: replies ?? this.replies,
    );
  }
}
