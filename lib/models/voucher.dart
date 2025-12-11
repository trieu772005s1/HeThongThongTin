import 'package:cloud_firestore/cloud_firestore.dart';

class Voucher {
  final String id;
  final String title;
  final String code;
  final int discount;
  final DateTime expiredAt;

  Voucher({
    required this.id,
    required this.title,
    required this.code,
    required this.discount,
    required this.expiredAt,
  });

  factory Voucher.fromMap(String id, Map<String, dynamic> data) {
    return Voucher(
      id: id,
      title: data['title'] ?? '',
      code: data['code'] ?? '',
      discount: data['discount'] ?? 0,
      expiredAt: (data['expiredAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'code': code,
      'discount': discount,
      'expiredAt': expiredAt,
    };
  }
}
