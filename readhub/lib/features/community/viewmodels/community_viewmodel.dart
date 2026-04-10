import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment_model.dart';
import '../repositories/community_repository.dart';

class CommunityViewModel extends ChangeNotifier {
  final CommunityRepository _repo = CommunityRepository();

  List<CommentModel> _comments = [];
  bool _isLoading = true;
  String _bookId = '';
  String _bookTitle = '';

  final List<String> chapters = ['Genel', 'Bölüm 1', 'Bölüm 2', 'Bölüm 3', 'Son Değerlendirme'];
  String _selectedChapter = 'Genel';

  StreamSubscription<List<CommentModel>>? _commentsSubscription;

  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  String get selectedChapter => _selectedChapter;
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // ── İLK YÜKLEME ─────────────────────────────────────────────────────────
  Future<void> loadDiscussion(String bookId, {String title = ''}) async {
    _bookId = bookId;
    _bookTitle = title;
    _isLoading = true;
    notifyListeners();

    // Seed data — kitabın hiç yorumu yoksa örnek yorumlar ekle
    await _repo.seedMockDataIfEmpty(bookId);

    // Seçili bölüm için stream'i başlat
    _subscribeToChapter();
  }

  void _subscribeToChapter() {
    _commentsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _commentsSubscription = _repo
        .commentsStream(_bookId, _selectedChapter)
        .listen((comments) {
      _comments = comments;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _isLoading = false;
      notifyListeners();
    });
  }

  // ── BÖLÜM DEĞİŞTİR ──────────────────────────────────────────────────────
  void selectChapter(String chapter) {
    if (_selectedChapter == chapter) return;
    _selectedChapter = chapter;
    _commentsSubscription?.cancel();
    _subscribeToChapter();
  }

  // ── YORUM EKLE ───────────────────────────────────────────────────────────
  Future<void> addComment(String text, bool isSpoiler) async {
    if (text.trim().isEmpty) return;
    await _repo.addComment(
      bookId: _bookId,
      text: text,
      isSpoiler: isSpoiler,
      chapterId: _selectedChapter,
      bookTitle: _bookTitle.isNotEmpty ? _bookTitle : 'Bilinmeyen Kitap',
    );
    // Stream otomatik güncelleyecek
  }

  // ── YANIT EKLE ───────────────────────────────────────────────────────────
  Future<void> addReply({
    required String parentCommentId,
    required String text,
    required bool isSpoiler,
  }) async {
    if (text.trim().isEmpty) return;
    await _repo.addReply(
      bookId: _bookId,
      parentCommentId: parentCommentId,
      text: text,
      isSpoiler: isSpoiler,
      chapterId: _selectedChapter,
    );
  }

  // ── YORUM BEĞENİ ─────────────────────────────────────────────────────────
  Future<void> toggleCommentLike(String commentId, bool currentlyLiked) async {
    // Optimistik güncelleme
    final idx = _comments.indexWhere((c) => c.id == commentId);
    if (idx != -1) {
      _comments[idx] = _comments[idx].withToggledLike(currentUserId);
      notifyListeners();
    }
    // Firestore'a yaz
    await _repo.toggleCommentLike(
      bookId: _bookId,
      commentId: commentId,
      currentlyLiked: currentlyLiked,
    );
  }

  // ── YANIT BEĞENİ ────────────────────────────────────────────────────────
  Future<void> toggleReplyLike({
    required String commentId,
    required String replyId,
    required bool currentlyLiked,
  }) async {
    await _repo.toggleReplyLike(
      bookId: _bookId,
      commentId: commentId,
      replyId: replyId,
      currentlyLiked: currentlyLiked,
    );
  }

  // ── REPLY STREAM ─────────────────────────────────────────────────────────
  Stream<List<CommentModel>> repliesStream(String commentId) {
    return _repo.repliesStream(_bookId, commentId);
  }

  // ── YORUM SİL ────────────────────────────────────────────────────────────
  Future<void> deleteComment(String commentId) async {
    await _repo.deleteComment(
      bookId: _bookId,
      commentId: commentId,
    );
    // Stream otomatik güncelleyecek
  }

  @override
  void dispose() {
    _commentsSubscription?.cancel();
    super.dispose();
  }
}
