import 'package:flutter/material.dart';
import '../../home/models/book_model.dart';
import '../../home/repositories/book_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookDetailViewModel extends ChangeNotifier {
  final BookRepository _repository = BookRepository();
  
  BookModel? _book;
  bool _isLoading = true;
  String _currentStatus = 'None';

  BookModel? get book => _book;
  bool get isLoading => _isLoading;
  String get currentStatus => _currentStatus;

  Future<void> loadBook(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _book = await _repository.getBookDetails(id);
      _book ??= BookModel.mock();
      // Also fetch user's saved reading status for this book
      _currentStatus = await _repository.getReadingStatus(id);
    } catch (_) {
      _book = BookModel.mock();
      _currentStatus = 'None';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String newStatus) async {
    if (_book == null) return;
    // Update UI immediately so user sees response right away
    _currentStatus = newStatus;
    notifyListeners();
    // Then persist to Firestore in background
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        await _repository.saveBookInteraction(uid, _book!, newStatus);
      }
    } catch (_) {
      // Ignore errors silently
    }
  }
}
