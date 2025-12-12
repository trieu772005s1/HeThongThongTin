import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final pass = TextEditingController();
  final confirm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text("Đặt mật khẩu mới")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Email: $email"),
            TextField(
              controller: pass,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mật khẩu mới"),
            ),
            TextField(
              controller: confirm,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: "Nhập lại mật khẩu mới"),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Xác nhận"),
            )
          ],
        ),
      ),
    );
  }
}
