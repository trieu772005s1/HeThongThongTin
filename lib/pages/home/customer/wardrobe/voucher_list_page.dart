import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fl_credit/models/voucher.dart';
import 'package:fl_credit/services/wardrobe_service.dart';

class VoucherListPage extends StatelessWidget {
  VoucherListPage({super.key}); // KHÔNG dùng const

  final WardrobeService service = WardrobeService();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Voucher')),

      body: StreamBuilder<List<Voucher>>(
        stream: service.getVouchers(userId),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

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
                      v.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Mã: ${v.code}"),
                    Text("Giảm: ${v.discount}%"),
                    Text("Hết hạn: ${v.expiredAt.toString().split(' ').first}"),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // =====================
  // POPUP TẠO VOUCHER
  // =====================
  void _openCreateVoucherDialog(BuildContext context, String userId) {
    final titleCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final discountCtrl = TextEditingController();
    final expiredCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Tạo Voucher"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Tên voucher"),
              ),
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: "Mã voucher"),
              ),
              TextField(
                controller: discountCtrl,
                decoration: const InputDecoration(labelText: "Giảm (%)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: expiredCtrl,
                decoration: const InputDecoration(
                  labelText: "Ngày hết hạn (YYYY-MM-DD)",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                final v = Voucher(
                  id: '',
                  title: titleCtrl.text,
                  code: codeCtrl.text,
                  discount: int.tryParse(discountCtrl.text) ?? 0,
                  expiredAt:
                      DateTime.tryParse(expiredCtrl.text) ?? DateTime.now(),
                );

                await service.addVoucher(userId, v);

                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text("Tạo"),
            ),
          ],
        );
      },
    );
  }

  // =====================
  // UI phụ
  // =====================

  Widget _empty(String text) => Center(
    child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.grey)),
  );

  BoxDecoration get _box => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.05),
        blurRadius: 6,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
