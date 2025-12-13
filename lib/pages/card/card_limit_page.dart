import 'package:flutter/material.dart';
import 'card_email_page.dart';
import 'package:intl/intl.dart';

class CardLimitPage extends StatefulWidget {
  const CardLimitPage({super.key});

  @override
  State<CardLimitPage> createState() => _CardLimitPageState();
}

class _CardLimitPageState extends State<CardLimitPage> {
  static const double _min = 1_000_000;
  static const double _max = 100_000_000;
  static const double _step = 1_000_000;

  double limit = 10_000_000;

  final _currencyFormat = NumberFormat('#,###', 'vi_VN');

  double _roundToStep(double value) {
    return (value / _step).round() * _step;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            // Progress
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                widthFactor: 0.2,
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

            Row(
              children: [
                Text(
                  _currencyFormat.format(limit),
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
              min: _min,
              max: _max,
              divisions: ((_max - _min) / _step).round(),
              value: limit,
              activeColor: const Color(0xFF1976D2),
              label: _currencyFormat.format(limit),
              onChanged: (v) {
                setState(() {
                  limit = _roundToStep(v);
                });
              },
            ),

            const SizedBox(height: 8),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("1.000.000 VND"), Text("100.000.000 VND")],
            ),

            const Spacer(),

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
}
