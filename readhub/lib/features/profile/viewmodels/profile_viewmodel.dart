import 'dart:async';
import 'package:flutter/material.dart';
import '../../home/models/book_model.dart';
import '../../home/repositories/book_repository.dart';
import '../../community/repositories/community_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileViewModel extends ChangeNotifier {
  final BookRepository _bookRepository = BookRepository();
  final CommunityRepository _communityRepository = CommunityRepository();
  
  bool _isLoading = true;
  StreamSubscription? _commentsSubscription;
  
  List<BookModel> _readingList = [];
  List<BookModel> _finishedList = [];
  List<BookModel> _wantToReadList = [];
  List<Map<String, dynamic>> _userComments = [];

  bool get isLoading => _isLoading;

  List<BookModel> get readingList => _readingList;
  List<BookModel> get finishedList => _finishedList;
  List<BookModel> get wantToReadList => _wantToReadList;
  List<Map<String, dynamic>> get userComments => _userComments;

  // Gerçek verilerle istatistik
  int get totalFinished => _finishedList.length;
  
  int get totalPagesRead {
    final finishedPages = _finishedList.fold(0, (sum, book) => sum + (book.totalPages > 0 ? book.totalPages : 0));
    final readingPages = _readingList.fold(0, (sum, book) => sum + (book.currentPage > 0 ? book.currentPage : 0));
    return finishedPages + readingPages;
  }

  ProfileViewModel() {
    loadProfileData();
    _initCommentsStream();
  }

  @override
  void dispose() {
    _commentsSubscription?.cancel();
    super.dispose();
  }

  void _initCommentsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      _commentsSubscription?.cancel();
      _commentsSubscription = _communityRepository.getUserCommentsStream(uid).listen((comments) {
        _userComments = comments;
        notifyListeners();
      }, onError: (e) {
        // Handle errors silently
      });
    }
  }

  Future<void> loadProfileData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        _readingList = await _bookRepository.getCurrentlyReading(uid);
        _finishedList = await _bookRepository.getFinishedBooks(uid);
        _wantToReadList = await _bookRepository.getWantToReadBooks(uid);
      }
    } catch (_) {
      // Ignored
    }

    _isLoading = false;
    notifyListeners();
  }
}
