import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initFCM() async{
    //izin isteme
    await _messaging.requestPermission();
    

    //token alma
    final token = await _messaging.getToken();
    print("🔥 FCM TOKEN: $token");

    if(token == null) return;

    final uid = _auth.currentUser?.uid;
    if(uid == null) return;

    //tokenı firestore'a kaydetme
    await _firestore.collection('users').doc(uid).update({
      'fcmToken': token,
    });

    //topic subscribe
    await _messaging.subscribeToTopic('allUsers');
  }
}