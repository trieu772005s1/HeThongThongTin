import 'package:flutter/material.dart';
import 'card_address_page.dart';

class CardEmailPage extends StatefulWidget {
  final double limit;
  const CardEmailPage({super.key, required this.limit});

  @override
  State<CardEmailPage> createState() => _CardEmailPageState();
}

class _CardEmailPageState extends State<CardEmailPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    if (email.isEmpty) return true; // cho phép bỏ qua
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(email);
  }

  void _next() {
    final email = _emailController.text.trim();

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email không hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardAddressPage(limit: widget.limit, email: email),
      ),
    );
  }

  void _skip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardAddressPage(limit: widget.limit, email: ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
                widthFactor: 0.4,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "Nhập Email",
              style: TextStyle(
                fontSize: 26,
                color: Color(0xFF002C5F),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Nhập email để nhận thông tin ưu đãi. Bạn có thể bỏ qua bước này.",
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF6A7A93),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              "Email",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF002C5F),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "example@gmail.com",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _skip,
                  child: const Text(
                    "Bỏ qua",
                    style: TextStyle(fontSize: 16, color: Color(0xFF1976D2)),
                  ),
                ),
                ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Tiếp theo",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
