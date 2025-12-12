import 'package:flutter/material.dart';
import 'card_email_page.dart';

class CardLimitPage extends StatefulWidget {
  const CardLimitPage({super.key});

  @override
  State<CardLimitPage> createState() => _CardLimitPageState();
}

class _CardLimitPageState extends State<CardLimitPage> {
  double limit = 10000000; // 10 triệu mặc định

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                widthFactor: 0.2, // bước 1
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 26),

            const Text(
              "Bạn mong muốn hạn mức thẻ là bao nhiêu?",
              style: TextStyle(
                fontSize: 25,
                color: Color(0xFF002C5F),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Hạn mức thẻ mong muốn",
              style: TextStyle(fontSize: 16, color: Color(0xFF6A7A93)),
            ),

            const SizedBox(height: 12),

            // Số tiền lớn
            Row(
              children: [
                Text(
                  _formatMoney(limit),
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002C5F),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  "VND",
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF002C5F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Slider(
              min: 1000000,
              max: 100000000,
              value: limit,
              activeColor: const Color(0xFF1976D2),
              onChanged: (v) {
                setState(() {
                  limit = v;
                });
              },
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [Text("1.000.000 VND"), Text("100.000.000 VND")],
            ),

            const Spacer(),

            // Nút Tiếp theo
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CardEmailPage(limit: limit),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Tiếp theo",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMoney(double amount) {
    final s = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buffer.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }
}
