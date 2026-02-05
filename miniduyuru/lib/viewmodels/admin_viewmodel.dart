import 'package:flutter/material.dart';
import 'package:miniduyuru/services/notification_service.dart';

class AdminViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  Future<bool> sendNotification() async {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      errorMessage = 'Lütfen tüm alanları doldurun';
      successMessage = null;
      notifyListeners();
      return false;
    }

    try {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      notifyListeners();

      await _notificationService.sendNotification(title: title, body: body);
      
      titleController.clear();
      bodyController.clear();
      
      successMessage = 'Duyuru başarıyla gönderildi ✓';
      return true;
    } catch (e) {
      errorMessage = 'Bildirim gönderilemedi: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Stream get notificationsStream {
    return _notificationService.getNotifications();
  }

  Future<bool> deleteNotification(String id) async {
    try {
      await _notificationService.deleteNotification(id);
      successMessage = 'Duyuru silindi';
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Duyuru silinemedi: $e';
      notifyListeners();
      return false;
    }
  }

  bool get isFormValid {
    return titleController.text.trim().isNotEmpty &&
           bodyController.text.trim().isNotEmpty;
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }
}