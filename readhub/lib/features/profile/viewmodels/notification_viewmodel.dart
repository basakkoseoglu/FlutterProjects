import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();
  List<NotificationModel> _notifications = [];
  StreamSubscription? _subscription;
  bool _isLoading = true;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => n.isUnread).length;

  NotificationViewModel() {
    _init();
  }

  void _init() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _subscription = _repository.getNotifications(user.uid).listen(
        (data) {
          _notifications = data;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Bildirimler alınırken hata oluştu: $error');
          _isLoading = false;
          notifyListeners();
        },
      );
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _repository.markAsRead(user.uid, id);
    }
  }

  Future<void> markAllAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _repository.markAllAsRead(user.uid);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
