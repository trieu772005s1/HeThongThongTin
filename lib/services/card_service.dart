import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CardService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> submitApplication({
    required double limit,
    required String email,
    required String province,
    required String district,
    required String ward,
    required String detail,
    required String financialType,
  }) async {
    final uid = _auth.currentUser!.uid;

    await _db.collection("card_applications").doc(uid).set({
      "uid": uid,
      "limit": limit,
      "email": email,
      "province": province,
      "district": district,
      "ward": ward,
      "detail": detail,
      "financialType": financialType,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String?> getApplicationStatus() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _db.collection("card_applications").doc(uid).get();

    if (!doc.exists) return null;
    return doc["status"];
  }
}
