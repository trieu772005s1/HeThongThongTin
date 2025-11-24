import 'package:fl_credit/pages/home/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_credit/pages/login_page.dart';
import 'package:fl_credit/pages/register_screen.dart';
import 'package:fl_credit/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:fl_credit/pages/home/home_selector.dart';

import 'package:fl_credit/pages/home/home_staff_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FL CREDIT',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        // Login + Đăng ký
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        // Sau đăng nhập luôn đi qua HomeSelector để check role
        '/home': (context) => const HomeSelectorPage(),

        // Thông báo
        '/notifications': (context) => const NotificationsPage(),

        // Nếu cần gọi thẳng (ít dùng)
        '/staffHome': (context) => const HomeStaffPage(userRole: 'staff'),
        '/adminHome': (context) => const HomeStaffPage(userRole: 'admin'),
      },
    );
  }
}
