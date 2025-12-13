import 'package:flutter/material.dart';

class TransactionPointPage extends StatelessWidget {
  const TransactionPointPage({super.key});

  // Danh sách điểm giao dịch ở TP.HCM
  final List<Map<String, String>> locations = const [
    {
      'name': 'PGD Nguyễn Thị Minh Khai',
      'address': '60 Nguyễn Thị Minh Khai, Q.1, TP.HCM',
    },
    {
      'name': 'PGD Lý Thường Kiệt',
      'address': '234 Lý Thường Kiệt, Q.10, TP.HCM',
    },
    {'name': 'PGD Quang Trung', 'address': '102 Quang Trung, Q.Gò Vấp, TP.HCM'},
    {
      'name': 'PGD Phan Văn Trị',
      'address': '45 Phan Văn Trị, Q.Bình Thạnh, TP.HCM',
    },
    {'name': 'PGD Tân Sơn Nhì', 'address': '87 Tân Sơn Nhì, Q.Tân Phú, TP.HCM'},
    {
      'name': 'PGD Trường Chinh',
      'address': '12 Trường Chinh, Q.Tân Bình, TP.HCM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Điểm giao dịch',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final item = locations[index];
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
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['address'] ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
