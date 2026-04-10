import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';

class BookRepository {
  final String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<BookModel>> searchBooks(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http.get(Uri.parse('$_baseUrl?q=$query&maxResults=10'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null) {
          return (data['items'] as List).map((item) => BookModel.fromGoogleBooks(item)).toList();
        }
      }
      return [];
    } catch (e, st) {
      print('=== searchBooks Error ===');
      print(e);
      print(st);
      return [];
    }
  }

  Future<List<BookModel>> getPopularBooks() async {
    final results = await searchBooks('subject:fiction&orderBy=relevance');
    if (results.isNotEmpty) return results;

    // Fallback if Google Books API is rate-limited (429) or fails
    return [
      BookModel(
        id: 'fallback_1',
        title: 'Gece Yarısı Kütüphanesi',
        author: 'Matt Haig',
        coverUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=400&auto=format&fit=crop',
        rating: 4.8,
        description: 'Yaşamla ölüm arasında bir kütüphane vardır ve bu kütüphanede raflar sonsuza kadar uzanır...',
      ),
      BookModel(
        id: 'fallback_2',
        title: 'Dune',
        author: 'Frank Herbert',
        coverUrl: 'https://images.unsplash.com/photo-1600189261867-30e5ffe7b8da?q=80&w=400&auto=format&fit=crop',
        rating: 4.9,
        description: 'Uzak bir gelecekte geçen, entrika, ihanet ve kurtuluş dolu muazzam bir bilimkurgu destanı.',
      ),
      BookModel(
        id: 'fallback_3',
        title: 'Olasılıksız',
        author: 'Adam Fawer',
        coverUrl: 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?q=80&w=400&auto=format&fit=crop',
        rating: 4.6,
        description: 'Hayatınızın en karmaşık denklemini çözmeye hazır mısınız?',
      ),
      BookModel(
        id: 'fallback_4',
        title: 'Simyacı',
        author: 'Paulo Coelho',
        coverUrl: 'https://images.unsplash.com/photo-1629196914275-f5e4860b7305?q=80&w=400&auto=format&fit=crop',
        rating: 4.7,
        description: 'Kendi kişisel menkıbesini arayan Endülüslü çoban Santiago\'nun büyüleyici öyküsü.',
      ),
    ];
  }

  /// Kullanıcının okuma geçmişinden yazarları çıkarır ve
  /// bu yazarlara/türlere göre gerçek kişiselleştirilmiş öneriler üretir.
  Future<List<BookModel>> getPersonalizedRecommendations(String uid) async {
    // 1. Kullanıcının okuma geçmişini çek
    List<String> readAuthors = [];
    Set<String> alreadyReadIds = {};

    if (uid.isNotEmpty) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(uid)
            .collection('reading_states')
            .get();

        for (final doc in snapshot.docs) {
          alreadyReadIds.add(doc.id);
          final author = doc.data()['author'] as String?;
          if (author != null && author.isNotEmpty && author != 'Unknown Author') {
            // Birden fazla yazar varsa ilkini al
            final firstAuthor = author.split(',').first.trim();
            if (!readAuthors.contains(firstAuthor)) {
              readAuthors.add(firstAuthor);
            }
          }
        }
      } catch (_) {
        // Firestore'a erişilemezse fallback'e geç
      }
    }

    final List<BookModel> recommendations = [];

    if (readAuthors.isNotEmpty) {
      // 2. Her yazara göre API'den benzer kitaplar çek (en fazla 3 yazar)
      final authorsToQuery = readAuthors.take(3).toList();

      for (final author in authorsToQuery) {
        try {
          final encoded = Uri.encodeComponent(author);
          final response = await http.get(
            Uri.parse('$_baseUrl?q=inauthor:$encoded&maxResults=5&orderBy=relevance'),
          );
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['items'] != null) {
              final books = (data['items'] as List)
                  .map((item) => BookModel.fromGoogleBooks(item))
                  // Kullanıcının zaten okuduğu kitapları çıkar
                  .where((b) => !alreadyReadIds.contains(b.id))
                  .toList();
              recommendations.addAll(books);
            }
          }
        } catch (_) {
          // Bu yazar için atla
        }
      }
    }

    // 3. Yeterli öneri yoksa (yeni kullanıcı) genel bestseller listesiyle doldur
    if (recommendations.length < 5) {
      try {
        final fallback = await searchBooks('subject:bestseller&orderBy=relevance');
        for (final book in fallback) {
          if (!alreadyReadIds.contains(book.id) &&
              !recommendations.any((r) => r.id == book.id)) {
            recommendations.add(book);
          }
        }
      } catch (_) {}
    }

    // 4. Çıktıyı karıştır ve maksimum 12 kitap döndür
    recommendations.shuffle(Random());
    return recommendations.take(12).toList();
  }

  Stream<List<BookModel>> getCurrentlyReadingStream(String uid) {
    if (uid.isEmpty) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('reading_states')
        .where('status', isEqualTo: 'Reading')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BookModel(
          id: doc.id,
          title: data['title'] ?? 'Bilinmeyen Kitap',
          author: data['author'] ?? 'Bilinmeyen Yazar',
          coverUrl: data['coverUrl'] ?? '',
          description: data['description'] ?? '',
          rating: (data['rating'] ?? 0.0).toDouble(),
          status: data['status'] ?? 'None',
          currentPage: data['currentPage'] ?? 0,
          totalPages: data['totalPages'] ?? 0,
        );
      }).toList();
    });
  }

  Future<List<BookModel>> getCurrentlyReading(String uid) async {
    if (uid.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('reading_states')
          .where('status', isEqualTo: 'Reading')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BookModel(
          id: doc.id,
          title: data['title'] ?? 'Bilinmeyen',
          author: data['author'] ?? 'Bilinmeyen',
          coverUrl: data['coverUrl'] ?? '',
          rating: (data['rating'] ?? 0.0).toDouble(),
          description: data['description'] ?? '',
          status: 'Reading',
          currentPage: (data['currentPage'] ?? 0) as int,
          totalPages: (data['totalPages'] ?? 0) as int,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<BookModel>> getFinishedBooks(String uid) async {
    if (uid.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('reading_states')
          .where('status', isEqualTo: 'Finished')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BookModel(
          id: doc.id,
          title: data['title'] ?? 'Bilinmeyen',
          author: data['author'] ?? 'Bilinmeyen',
          coverUrl: data['coverUrl'] ?? '',
          rating: (data['rating'] ?? 0.0).toDouble(),
          description: data['description'] ?? '',
          status: 'Finished',
          currentPage: (data['currentPage'] ?? 0) as int,
          totalPages: (data['totalPages'] ?? 0) as int,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<BookModel>> getWantToReadBooks(String uid) async {
    if (uid.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('reading_states')
          .where('status', isEqualTo: 'Want to Read') // Wait wait, earlier we translated it to Want to Read in firestore?
          // Let's use the english string since it's used that way in firestore saving in book detail.
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BookModel(
          id: doc.id,
          title: data['title'] ?? 'Bilinmeyen',
          author: data['author'] ?? 'Bilinmeyen',
          coverUrl: data['coverUrl'] ?? '',
          rating: (data['rating'] ?? 0.0).toDouble(),
          description: data['description'] ?? '',
          status: 'Want to Read',
          currentPage: (data['currentPage'] ?? 0) as int,
          totalPages: (data['totalPages'] ?? 0) as int,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> savePageProgress(String uid, String bookId, int currentPage, int totalPages) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('reading_states')
          .doc(bookId)
          .update({
        'currentPage': currentPage,
        'totalPages': totalPages,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Ignore
    }
  }

  Future<void> saveBookInteraction(String uid, BookModel book, String status) async {
    // 1. Write user's reading state FIRST — this is the critical data
    final stateData = book.toMap();
    stateData['status'] = status;
    stateData['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('reading_states')
        .doc(book.id)
        .set(stateData, SetOptions(merge: true));

    // 2. Attempt to cache in global books collection for popularity tracking.
    // This may fail if Firestore rules don't allow writes — that's OK,
    // the reading state above is already saved.
    try {
      await _firestore
          .collection('books')
          .doc(book.id)
          .set(book.toMap(), SetOptions(merge: true));
    } catch (_) {
      // Silently ignore — books cache is optional
    }
  }

  Future<String> getReadingStatus(String bookId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || uid.isEmpty) return 'None';

      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('reading_states')
          .doc(bookId)
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!['status'] as String? ?? 'None';
      }
      return 'None';
    } catch (e) {
      return 'None';
    }
  }

  Future<BookModel?> getBookDetails(String bookId) async {
    // 1. Try Firestore cache first
    try {
      final doc = await _firestore.collection('books').doc(bookId).get();
      if (doc.exists && doc.data() != null) {
        return BookModel.fromFirestore(doc.data()!, doc.id);
      }
    } catch (e) {
      // Ignore Firestore errors, fall through to API
    }

    // 2. Fetch from Google Books API
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$bookId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BookModel.fromGoogleBooks(data);
      }
    } catch (e) {
      // Ignore HTTP errors
    }

    return null;
  }
}
