import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> notifications = [
      'Bạn có kỳ thanh toán đến hạn vào 20/11/2025',
      'Hợp đồng #12345 đã được duyệt',
      'Thanh toán kỳ 3 thành công',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.orange),
              title: Text(notifications[index]),
            ),
          );
        },
      ),
    );
  }
}
