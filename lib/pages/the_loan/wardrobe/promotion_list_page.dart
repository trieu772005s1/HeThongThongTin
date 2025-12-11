import 'package:flutter/material.dart';

class PromotionListPage extends StatelessWidget {
  const PromotionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final promotions = <String>[]; // TODO: lấy từ server

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ưu đãi'),
      ),
      body: promotions.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: promotions.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(promotions[index]),
                );
              },
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.percent, size: 56, color: Colors.blue.shade600),
            const SizedBox(height: 16),
            const Text(
              'Chưa có ưu đãi khả dụng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Các ưu đãi đặc biệt sẽ được hiển thị tại đây khi bạn đủ điều kiện.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
