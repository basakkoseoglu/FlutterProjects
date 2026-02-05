import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserViewModel extends ChangeNotifier {
   Stream<QuerySnapshot<Map<String, dynamic>>>? get notificationsStream {
    final user=FirebaseAuth.instance.currentUser;

    if(user== null) return null;
    return FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}