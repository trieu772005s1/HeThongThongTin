import 'package:flutter/material.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FD),
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(
        color: Colors.white,  // 👉 arrow trắng
       ),
        backgroundColor: const Color(0xFF1976D2),
        title: const Text(
          'Tủ đồ',
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,),
        ),
      ),
      body: Column(
        children: [
          // Phần header màu cam/gradient phía trên
          

          const SizedBox(height: 16),

          // Card nội dung
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 35, right: 16),
              child: Wrap(
                 
                spacing: 35,
                runSpacing: 16,
                children: [
                  _buildItemCard(
                    title: 'Phần quà',
                    countText: 'Hiện có 0',
                    icon: Icons.card_giftcard,
                    iconBg: const Color(0xFFFFE5E5),
                    iconColor: const Color(0xFFE53935),
                  ),
                  _buildItemCard(
                    title: 'Voucher',
                    countText: 'Hiện có 0',
                    icon: Icons.confirmation_num,
                    iconBg: const Color(0xFFFFF0D7),
                    iconColor: const Color(0xFFFF9800),
                  ),
                  _buildItemCard(
                    title: 'Ưu đãi',
                    countText: 'Hiện có 0',
                    icon: Icons.percent,
                    iconBg: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF1976D2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildItemCard({
  required String title,
  required String countText,
  required IconData icon,
  required Color iconBg,
  required Color iconColor,
}) {
  return Container(
    width: 150,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        )
      ],
    ),
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: iconBg,
          child: Icon(icon, color: iconColor, size: 26),
        ),
        const SizedBox(height: 14),

        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          countText,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    ),
  );
}

}