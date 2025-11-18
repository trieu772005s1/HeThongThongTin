import 'package:fl_credit/pages/home/customer/home_customer_page.dart';
import 'package:fl_credit/pages/home/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_credit/pages/login_page.dart';
import 'package:fl_credit/pages/register_screen.dart';
import 'package:fl_credit/theme/app_theme.dart';

// THÊM 2 DÒNG NÀY
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // THÊM 3 DÒNG NÀY
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
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomeCustomerPage(),
        '/notifications': (context) => const NotificationsPage(),
      },
    );
  }
}
