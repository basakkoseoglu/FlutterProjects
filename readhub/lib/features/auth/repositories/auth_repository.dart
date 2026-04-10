import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'dart:async';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> login(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return await getUserData(credential.user!.uid);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<UserModel> signup(String email, String password, String username) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      
      // Update Firebase Profile
      await user.updateDisplayName(username);
      
      // Create user data in Firestore
      final userModel = UserModel(
        id: user.uid,
        email: email,
        username: username,
        profilePhotoUrl: 'https://ui-avatars.com/api/?name=$username&background=random',
        favoriteGenres: [],
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel;
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  Future<UserModel> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      UserModel user = UserModel.fromMap(doc.data()!, doc.id);
      
      // Streak kontrolü
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      int newStreak = user.streakDays == 0 ? 1 : user.streakDays;
      bool updateNeeded = false;
      
      if (user.lastActiveDate != null) {
        final lastActive = DateTime(
          user.lastActiveDate!.year, 
          user.lastActiveDate!.month, 
          user.lastActiveDate!.day
        );
        final difference = today.difference(lastActive).inDays;
        
        if (difference == 1) {
          // Dün girdi, bugün devam ediyor
          newStreak += 1;
          updateNeeded = true;
        } else if (difference > 1) {
          // Bir günden fazla ara vermiş
          newStreak = 1;
          updateNeeded = true;
        } else if (difference == 0 && user.streakDays == 0) {
          // Aynı gün ama nedense streak 0 kalmış
          newStreak = 1;
          updateNeeded = true;
        }
      } else {
        // İlk giriş
        newStreak = 1;
        updateNeeded = true;
      }
      
      // Eğer güncellenmesi gerekiyorsa (veya lastActiveDate bugünden eskiyse), firestore'u güncelle
      final lastActiveIsOld = user.lastActiveDate == null || 
          DateTime(user.lastActiveDate!.year, user.lastActiveDate!.month, user.lastActiveDate!.day).isBefore(today);
          
      if (updateNeeded || lastActiveIsOld) {
        user = UserModel(
          id: user.id,
          email: user.email,
          username: user.username,
          profilePhotoUrl: user.profilePhotoUrl,
          favoriteGenres: user.favoriteGenres,
          followersCount: user.followersCount,
          followingCount: user.followingCount,
          streakDays: newStreak,
          lastActiveDate: now,
        );
        
        await _firestore.collection('users').doc(user.id).update({
          'streakDays': newStreak,
          'lastActiveDate': FieldValue.serverTimestamp(),
        });
      }
      
      return user;
    } else {
      throw Exception('User data not found');
    }
  }

  Future<void> updateProfilePhoto(String userId, String photoUrl) async {
    await _firestore.collection('users').doc(userId).update({
      'profilePhotoUrl': photoUrl,
    });
    
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.uid == userId) {
      await currentUser.updatePhotoURL(photoUrl);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}

