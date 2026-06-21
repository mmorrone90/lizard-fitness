import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.onboardingCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      displayName: d['displayName'] ?? '',
      email: d['email'] ?? '',
      avatarUrl: d['avatarUrl'],
      onboardingCompleted: d['onboardingCompleted'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'displayName': displayName,
    'email': email,
    'avatarUrl': avatarUrl,
    'onboardingCompleted': onboardingCompleted,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  UserModel copyWith({
    String? displayName,
    String? avatarUrl,
    bool? onboardingCompleted,
    DateTime? updatedAt,
  }) =>
      UserModel(
        id: id,
        displayName: displayName ?? this.displayName,
        email: email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
