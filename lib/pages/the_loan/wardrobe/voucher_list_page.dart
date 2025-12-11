import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../models/voucher.dart';
import '../../../../services/wardrobe_service.dart';

class VoucherListPage extends StatelessWidget {
  VoucherListPage({super.key});   // KHÔNG dùng const

  final WardrobeService service = WardrobeService();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Voucher')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.getVouchers(userId),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final items = snapshot.data!;
          if (items.isEmpty) return _empty("Bạn chưa có voucher nào");

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final v = items[i];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: _box,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Mã: ${v['code'] ?? ''}"),
                    Text("Giảm: ${v['discount'] ?? 0}%"),
                    Text("Hết hạn: ${(v['expiredAt'] is DateTime ? v['expiredAt'].toString().split(' ').first : v['expiredAt']?.toString()?.split(' ')?.first ?? '')}"),
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
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
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
