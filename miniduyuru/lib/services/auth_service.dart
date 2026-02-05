import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;


  Future<User?> signIn(String email,String password) async{
    final result = await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password
      );
      return result.user;
  }

  Future<void> signOut() async{
    await _auth.signOut();
  }

  Future<bool> isAdmin(String uid) async {
  final doc = await _firestore.collection('users').doc(uid).get();
  if (!doc.exists) return false;

  return doc.data()?['role'] == 'admin';
}

}