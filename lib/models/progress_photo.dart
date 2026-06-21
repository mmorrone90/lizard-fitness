import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressPhoto {
  final String id;
  final String userId;
  final String imageUrl;
  final String? caption;
  final DateTime takenAt;
  final DateTime createdAt;

  const ProgressPhoto({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.caption,
    required this.takenAt,
    required this.createdAt,
  });

  factory ProgressPhoto.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ProgressPhoto(
      id: doc.id,
      userId: d['userId'] ?? '',
      imageUrl: d['imageUrl'] ?? '',
      caption: d['caption'],
      takenAt: (d['takenAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'imageUrl': imageUrl,
    'caption': caption,
    'takenAt': Timestamp.fromDate(takenAt),
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

class Milestone {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String type;
  final DateTime achievedAt;
  final DateTime createdAt;

  const Milestone({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.achievedAt,
    required this.createdAt,
  });

  factory Milestone.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Milestone(
      id: doc.id,
      userId: d['userId'] ?? '',
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      type: d['type'] ?? '',
      achievedAt: (d['achievedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class GymChallenge {
  final String id;
  final String title;
  final String description;
  final String type;
  final String goal;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  const GymChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.goal,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });

  factory GymChallenge.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return GymChallenge(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      type: d['type'] ?? '',
      goal: d['goal'] ?? '',
      startDate: (d['startDate'] as Timestamp?)?.toDate(),
      endDate: (d['endDate'] as Timestamp?)?.toDate(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  bool get isActive {
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }
}
