import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  reply,
  like,
  system,
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String subtitle;
  final String? bookId;
  final bool isUnread;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.bookId,
    this.isUnread = true,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    NotificationType type = NotificationType.system;
    if (data['type'] == 'reply') type = NotificationType.reply;
    if (data['type'] == 'like') type = NotificationType.like;

    return NotificationModel(
      id: doc.id,
      type: type,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      bookId: data['bookId'],
      isUnread: data['isUnread'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'bookId': bookId,
      'isUnread': isUnread,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
