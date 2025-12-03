import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  Future<void> _callHotline() async {
    final Uri url = Uri(scheme: 'tel', path: '0962392122'); // Hotline FE Credit
    await launchUrl(url);
  }

  Future<void> _openZalo() async {
    final Uri url = Uri.parse(
      'https://zalo.me/0962392122',
    ); // thay số zalo hỗ trợ của bạn
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _sendMail() async {
    final Uri url = Uri(
      scheme: 'mailto',
      path: 'hotro@fecredit.com.vn',
      query: 'subject=Hỗ trợ khách hàng',
    );
    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liên hệ hỗ trợ"),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _supportButton("Gọi tổng đài", Icons.call, _callHotline),
            _supportButton("Chat Zalo", Icons.chat, _openZalo),
            _supportButton("Gửi email hỗ trợ", Icons.email, _sendMail),
          ],
        ),
      ),
    );
  }

  Widget _supportButton(String text, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(
          icon,
          size: 22,
          color: Colors.white, // THÊM DÒNG NÀY
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white, // THÊM DÒNG NÀY
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFF1976D2),
        ),
        onPressed: onTap,
      ),
    );
  }
}
