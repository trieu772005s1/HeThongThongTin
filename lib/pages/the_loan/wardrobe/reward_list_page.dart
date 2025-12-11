import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../models/reward.dart';
import '../../../../services/wardrobe_service.dart';


class RewardListPage extends StatelessWidget {
  RewardListPage({super.key});   // KHÔNG được dùng const

  final WardrobeService service = WardrobeService();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Phần quà')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.getRewards(userId),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rewards = snapshot.data!;
          if (rewards.isEmpty) return _empty("Bạn chưa có phần quà nào");

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rewards.length,
            itemBuilder: (_, i) {
              final r = rewards[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: _box,
                child: Row(
                  children: [
                    Text(r['icon'] ?? '🎁', style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r['title'] ?? '',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            r['description'] ?? '',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _empty(String text) => Center(
        child:
            Text(text, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      );

  BoxDecoration get _box => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      );
}
