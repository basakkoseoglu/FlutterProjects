class BookModel {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final double rating;
  final String description;
  final String status; // 'Want to Read', 'Reading', 'Finished', 'None'
  final int currentPage;
  final int totalPages;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.rating,
    required this.description,
    this.status = 'None',
    this.currentPage = 0,
    this.totalPages = 0,
  });

  // Hesaplanan ilerleme (0.0 - 1.0)
  double get readingProgress {
    if (totalPages <= 0) return 0.0;
    return (currentPage / totalPages).clamp(0.0, 1.0);
  }

  int get readingProgressPercent => (readingProgress * 100).round();

  factory BookModel.fromGoogleBooks(Map<String, dynamic> item) {
    final Map<String, dynamic> volumeInfo = item['volumeInfo'] ?? {};
    final String title = volumeInfo['title'] ?? 'Bilinmeyen Başlık';
    
    String author = 'Bilinmeyen Yazar';
    if (volumeInfo['authors'] != null && (volumeInfo['authors'] as List).isNotEmpty) {
      author = (volumeInfo['authors'] as List).join(', ');
    }

    String coverUrl = 'https://via.placeholder.com/150x200.png?text=Kapak+Yok';
    if (volumeInfo['imageLinks'] != null) {
      coverUrl = volumeInfo['imageLinks']['thumbnail'] ?? 
                 volumeInfo['imageLinks']['smallThumbnail'] ?? 
                 coverUrl;
      // Google Books API returns http by default in some cases, replace with https to avoid mixed content errors 
      coverUrl = coverUrl.replaceAll('http://', 'https://');
    }

    String description = volumeInfo['description'] ?? 'Açıklama bulunamadı.';
    double rating = (volumeInfo['averageRating'] ?? 0.0).toDouble();

    return BookModel(
      id: item['id'] ?? 'bilinmeyen_id',
      title: title,
      author: author,
      coverUrl: coverUrl,
      rating: rating,
      description: description,
    );
  }

  factory BookModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return BookModel(
      id: docId,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      coverUrl: data['coverUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      status: data['status'] ?? 'None',
      currentPage: (data['currentPage'] ?? 0) as int,
      totalPages: (data['totalPages'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'rating': rating,
      'description': description,
      'currentPage': currentPage,
      'totalPages': totalPages,
    };
  }

  factory BookModel.mock() {
    return BookModel(
      id: 'mock_book_1',
      title: 'The Midnight Library',
      author: 'Matt Haig',
      coverUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=400&auto=format&fit=crop',
      rating: 4.8,
      description: 'Yaşamla ölüm arasında bir kütüphane vardır ve bu kütüphanede raflar sonsuza kadar uzanır...',
    );
  }
}
