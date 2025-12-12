import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'reward_list_page.dart';
import 'voucher_list_page.dart';
import 'promotion_list_page.dart';
import '../../../../services/wardrobe_service.dart';

class WardrobePage extends StatelessWidget {
  WardrobePage({super.key});

  final WardrobeService service = WardrobeService();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tủ đồ'),
      ),
      backgroundColor: const Color(0xfff3f8ff),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<Map<String, int>>(
          stream: _countsStream(userId),
          builder: (_, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final counts = snap.data!;

            return Row(
              children: [
                Expanded(
                  child: _WardrobeCard(
                    title: 'Phần quà',
                    subtitle: 'Hiện có ${counts["reward"]}',
                    icon: Icons.card_giftcard,
                    iconBgColor: Colors.pink.shade50,
                    iconColor: Colors.pink.shade400,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RewardListPage(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _WardrobeCard(
                    title: 'Voucher',
                    subtitle: 'Hiện có ${counts["voucher"]}',
                    icon: Icons.confirmation_number_outlined,
                    iconBgColor: Colors.amber.shade50,
                    iconColor: Colors.amber.shade600,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VoucherListPage(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _WardrobeCard(
                    title: 'Ưu đãi',
                    subtitle: 'Hiện có ${counts["promotion"]}',
                    icon: Icons.percent,
                    iconBgColor: Colors.lightBlue.shade50,
                    iconColor: Colors.lightBlue.shade600,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PromotionListPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==========================
  // ĐẾM SỐ LƯỢNG REWARD/VOUCHER/PROMO
  // ==========================
  Stream<Map<String, int>> _countsStream(String userId) {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    final rewardRef = userDoc.collection('rewards');
    final voucherRef = userDoc.collection('vouchers');
    final promoRef = userDoc.collection('promotions');

    return userDoc.snapshots().asyncMap((_) async {
      final r = await rewardRef.get();
      final v = await voucherRef.get();
      final p = await promoRef.get();

      return {
        "reward": r.docs.length,
        "voucher": v.docs.length,
        "promotion": p.docs.length,
      };
    });
  }
}

class _WardrobeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _WardrobeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
