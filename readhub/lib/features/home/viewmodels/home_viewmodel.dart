import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../repositories/book_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeViewModel extends ChangeNotifier {
  final BookRepository _repository = BookRepository();
  StreamSubscription? _readingSubscription;

  List<BookModel> _popularBooks = [];
  List<BookModel> _recommendedBooks = [];
  List<BookModel> _currentlyReading = [];
  List<BookModel> _finishedBooks = [];
  List<BookModel> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';

  List<BookModel> get popularBooks => _popularBooks;
  List<BookModel> get recommendedBooks => _recommendedBooks;
  List<BookModel> get currentlyReading => _currentlyReading;
  List<BookModel> get finishedBooks => _finishedBooks;
  List<BookModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  HomeViewModel() {
    loadHomeData();
    _initReadingStream();
  }

  @override
  void dispose() {
    _readingSubscription?.cancel();
    super.dispose();
  }

  void _initReadingStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      _readingSubscription?.cancel();
      _readingSubscription = _repository.getCurrentlyReadingStream(uid).listen((books) {
        _currentlyReading = books;
        notifyListeners();
      });
    }
  }

  Future<void> loadHomeData() async {
    _setLoading(true);

    _popularBooks = await _repository.getPopularBooks();

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    // Kişiselleştirilmiş öneriler — okunan yazarlara göre
    _recommendedBooks = await _repository.getPersonalizedRecommendations(uid);
    // _currentlyReading will be handled by stream
    _finishedBooks = await _repository.getFinishedBooks(uid);

    _setLoading(false);
  }

  Future<void> searchBooks(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();
    _searchResults = await _repository.searchBooks(query);
    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
