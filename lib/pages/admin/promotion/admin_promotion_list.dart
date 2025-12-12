import 'package:flutter/material.dart';
import '../../../../services/wardrobe_service.dart';
import '../../../../models/promotion.dart';

class AdminPromotionList extends StatelessWidget {
  AdminPromotionList({super.key});

  final WardrobeService service = WardrobeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ưu đãi')),
      body: StreamBuilder<List<Promotion>>(
        stream: service.getPromotions(), // ĐÃ SỬA ĐÚNG KIỂU
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

              final title = p.title;
              final desc = p.description;

              final startText = p.startAt.toString().split(' ').first;

              final endText = p.endAt.toString().split(' ').first;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: _box,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),
                    Text(desc),

                    const SizedBox(height: 4),
                    Text(
                      "Hiệu lực: $startText → $endText",
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
