import 'package:flutter/material.dart';
import '../../../../models/promotion.dart';
import '../../../../services/wardrobe_service.dart';

class PromotionListPage extends StatelessWidget {
  PromotionListPage({super.key});   // KHÔNG dùng const

  final WardrobeService service = WardrobeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ưu đãi')),
      body: StreamBuilder<List<Promotion>>(
        stream: service.getPromotions(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return _empty("Chưa có ưu đãi khả dụng");
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final p = items[i];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: _box,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(p.description),
                    const SizedBox(height: 4),
                    Text(
                      "Hiệu lực: ${p.startAt.toString().split(' ').first} → ${p.endAt.toString().split(' ').first}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
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
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      );
}
