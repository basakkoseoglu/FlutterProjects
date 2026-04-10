import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String profilePhotoUrl;
  final List<String> favoriteGenres;
  final int followersCount;
  final int followingCount;
  final int streakDays;
  final DateTime? lastActiveDate;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.profilePhotoUrl,
    required this.favoriteGenres,
    this.followersCount = 0,
    this.followingCount = 0,
    this.streakDays = 0,
    this.lastActiveDate,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      profilePhotoUrl: data['profilePhotoUrl'] ?? '',
      favoriteGenres: List<String>.from(data['favoriteGenres'] ?? []),
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      streakDays: data['streakDays'] ?? 0,
      lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'profilePhotoUrl': profilePhotoUrl,
      'favoriteGenres': favoriteGenres,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'streakDays': streakDays,
      if (lastActiveDate != null)
        'lastActiveDate': Timestamp.fromDate(lastActiveDate!),
    };
  }

}
