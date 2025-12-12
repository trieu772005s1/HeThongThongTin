import 'package:flutter/material.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({super.key});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text("Xác minh OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("OTP đã gửi tới: $email"),
            TextField(
              controller: _otpController,
              maxLength: 6,
              decoration: const InputDecoration(labelText: "Nhập OTP"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/resetPassword",
                    arguments: email);
              },
              child: const Text("Xác nhận"),
            )
          ],
        ),
      ),
    );
  }
}
