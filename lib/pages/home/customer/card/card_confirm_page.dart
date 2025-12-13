import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardConfirmPage extends StatelessWidget {
  final int limit;
  final String email;
  final String province;
  final String district;
  final String ward;
  final String fullAddress;
  final String financialMethod;

  const CardConfirmPage({
    super.key,
    required this.limit,
    required this.email,
    required this.province,
    required this.district,
    required this.ward,
    required this.fullAddress,
    required this.financialMethod,
  });

  Future<void> _submit(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final now = FieldValue.serverTimestamp();

    final batch = FirebaseFirestore.instance.batch();

    // 1. Lưu hồ sơ đăng ký thẻ
    final cardRef = FirebaseFirestore.instance
        .collection('card_applications')
        .doc(uid);

    batch.set(cardRef, {
      "limit": limit,
      "email": email,
      "province": province,
      "district": district,
      "ward": ward,
      "fullAddress": fullAddress,
      "financialMethod": financialMethod,
      "status": "PENDING",
      "createdAt": now,
    });

    // 2. Cập nhật trạng thái thẻ của user (QUAN TRỌNG)
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    batch.update(userRef, {
      "creditCard": {"status": "PENDING", "limit": limit, "requestedAt": now},
    });

    await batch.commit();

    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Xác nhận thông tin mở thẻ"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vui lòng kiểm tra và xác nhận lại thông tin",
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _info("Hạn mức thẻ", "$limit VND"),
                  _info("Email", email),
                  _info("Tỉnh / Thành phố", province),
                  _info("Quận / Huyện", district),
                  _info("Phường / Xã", ward),
                  _info("Địa chỉ đầy đủ", fullAddress),
                  _info("Hình thức chứng minh tài chính", financialMethod),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submit(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Gửi đăng ký",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
