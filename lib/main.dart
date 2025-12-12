import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Login / Register
import 'pages/login_page.dart';
import 'pages/register_screen.dart';

// HOME
import 'pages/home/home_selector.dart';
import 'pages/home/notification_page.dart';
import 'pages/home/home_staff_page.dart';

// USER WARDROBE (đúng theo hình bạn gửi)
import 'pages/the_loan/wardrobe/wardrobe_page.dart';
import 'pages/the_loan/wardrobe/reward_list_page.dart';
import 'pages/the_loan/wardrobe/voucher_list_page.dart';
import 'pages/the_loan/wardrobe/promotion_list_page.dart';

// ADMIN – USER BENEFIT
import 'pages/admin/wardrobe/admin_user_list_page.dart';
import 'pages/admin/wardrobe/admin_user_benefit_page.dart';

// ADMIN – PROMOTION
import 'pages/admin/promotion/admin_promotion_list.dart';
import 'pages/admin/promotion/admin_promotion_form.dart';

// THEME
import 'package:fl_credit/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),

        '/home': (context) => HomeSelectorPage(),
        '/notifications': (context) => NotificationsPage(),

        '/staffHome': (context) => HomeStaffPage(userRole: 'staff'),
        '/adminHome': (context) => HomeStaffPage(userRole: 'admin'),

        // USER WARDROBE
        '/wardrobe': (context) => WardrobePage(),
        '/rewards': (context) => RewardListPage(),
        '/vouchers': (context) => VoucherListPage(),
        '/promotions': (context) => PromotionListPage(),

        // ADMIN USER LIST
        '/admin-user-list': (context) => AdminUserListPage(),

        // ADMIN user benefit
        '/admin-user-benefit': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return AdminUserBenefitPage(
            userId: args['userId'],
            userName: args['userName'],
          );
        },

        // ADMIN PROMOTION
        '/admin-promotions': (context) => AdminPromotionList(),
        '/admin-promotion-create': (context) => AdminPromotionForm(),
      },
    );
  }
}
