import 'package:cloud_firestore/cloud_firestore.dart';

class Reward {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime createdAt;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.createdAt,
  });

  factory Reward.fromMap(String id, Map<String, dynamic> data) {
    return Reward(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '🎁',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'icon': icon,
      'createdAt': createdAt,
    };
  }
}
