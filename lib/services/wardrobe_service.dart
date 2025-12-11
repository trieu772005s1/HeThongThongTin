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
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return Reward.fromMap(d.id, data);
      }).toList();
    });
  }

  Future<void> addReward(String userId, Reward reward) async {
    await _db
        .collection("users")
        .doc(userId)
        .collection("rewards")
        .add(reward.toMap());
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
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return Voucher.fromMap(d.id, data);
      }).toList();
    });
  }

  Future<void> addVoucher(String userId, Voucher voucher) async {
    await _db
        .collection("users")
        .doc(userId)
        .collection("vouchers")
        .add(voucher.toMap());
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
  // PROMOTION (ưu đãi)
  // ============================================================
  Stream<List<Promotion>> getPromotions() {
    return _db.collection("promotions").snapshots().map((snap) {
      return snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return Promotion.fromMap(d.id, data);
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
