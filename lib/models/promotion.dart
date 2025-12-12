import 'package:cloud_firestore/cloud_firestore.dart';

class Promotion {
  final String id;
  final String title;
  final String description;
  final DateTime startAt;
  final DateTime endAt;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.startAt,
    required this.endAt,
  });

  factory Promotion.fromMap(String id, Map<String, dynamic> data) {
    return Promotion(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startAt: (data['startAt'] as Timestamp).toDate(),
      endAt: (data['endAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startAt': startAt,
      'endAt': endAt,
    };
  }
}
