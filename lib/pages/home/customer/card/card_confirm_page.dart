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

  Future<void> submitApplication() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("card_applications")
        .doc(uid)
        .set({
          "limit": limit,
          "email": email,
          "province": province,
          "district": district,
          "ward": ward,
          "fullAddress": fullAddress,
          "financialMethod": financialMethod,
          "status": "pending",
          "createdAt": DateTime.now(),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  infoRow("Hạn mức thẻ", "$limit VND"),
                  infoRow("Email", email),
                  infoRow("Tỉnh / Thành phố", province),
                  infoRow("Quận / Huyện", district),
                  infoRow("Phường / Xã", ward),
                  infoRow("Địa chỉ đầy đủ", fullAddress),
                  infoRow("Hình thức chứng minh tài chính", financialMethod),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await submitApplication();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
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

  Widget infoRow(String title, String value) {
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
