import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reward.dart';
import '../models/voucher.dart';
import '../models/promotion.dart';

class WardrobeService {
  final _db = FirebaseFirestore.instance;

  // ============================================================
  // REWARD
  // ============================================================
  Stream<List<Reward>> getRewards(String userId) {
    return _db
        .collection("users")
        .doc(userId)
        .collection("rewards")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        return Reward.fromMap(d.id, d.data());
      }).toList();
    });
  }

  Future<void> addReward(String userId, Reward reward) async {
    final ref =
        _db.collection("users").doc(userId).collection("rewards").doc();

    await ref.set({
      "id": ref.id,
      ...reward.toMap(),
      "createdAt": Timestamp.now(),
    });
  }

  Future<void> deleteReward(String userId, String rewardId) async {
    await _db
        .collection("users")
        .doc(userId)
        .collection("rewards")
        .doc(rewardId)
        .delete();
  }

  // ============================================================
// VOUCHER
// ============================================================
Stream<List<Voucher>> getVouchers(String userId) {
  return _db
      .collection("users")
      .doc(userId)
      .collection("vouchers")
      .orderBy("expiredAt")
      .snapshots()
      .map((snap) {
    return snap.docs.map((d) {
      // d.id: String, d.data(): Map<String, dynamic>
      return Voucher.fromMap(
        d.id,
        d.data() as Map<String, dynamic>,
      );
    }).toList();
  });
}

Future<void> addVoucher(String userId, Voucher voucher) async {
  final ref =
      _db.collection("users").doc(userId).collection("vouchers").doc();

  await ref.set({
    "id": ref.id,
    ...voucher.toMap(),
    "createdAt": Timestamp.now(),
  });
}

Future<void> deleteVoucher(String userId, String voucherId) async {
  await _db
      .collection("users")
      .doc(userId)
      .collection("vouchers")
      .doc(voucherId)
      .delete();
}

  // ============================================================
  // PROMOTION
  // ============================================================
  Stream<List<Promotion>> getPromotions() {
    return _db.collection("promotions").snapshots().map((snap) {
      return snap.docs.map((d) {
        return Promotion.fromMap(d.id, d.data());
      }).toList();
    });
  }

  Future<void> addPromotion(Promotion p) async {
    await _db.collection("promotions").add(p.toMap());
  }

  Future<void> updatePromotion(String id, Promotion p) async {
    await _db.collection("promotions").doc(id).update(p.toMap());
  }

  Future<void> deletePromotion(String id) async {
    await _db.collection("promotions").doc(id).delete();
  }
}
