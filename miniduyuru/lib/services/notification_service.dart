import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


 //bildirm gönderme
  Future<void> sendNotification({
    required String title,
    required String body,
  }) async {
    await _firestore.collection('notifications').add({
      'title': title,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
    });   
  }

  //bildirimleri dinleme
  Stream<QuerySnapshot> getNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  //duyuru silme
  Future<void> deleteNotification(String id) async{
    await _firestore.collection('notifications').doc(id).delete();
  }
}