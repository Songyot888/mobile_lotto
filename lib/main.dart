import 'package:flutter/material.dart';
import 'package:mobile_lotto/page/load_page.dart';
import 'package:mobile_lotto/page/history_page.dart';
import 'package:mobile_lotto/page/login_page.dart';
import 'package:mobile_lotto/page/menu_page.dart';
import 'package:mobile_lotto/page/personal_page.dart';
import 'package:mobile_lotto/page/profile_page.dart';
import 'package:mobile_lotto/page/register_page.dart';
import 'package:mobile_lotto/page/wallet_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lotto888',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4D01FF)),
      ),

      initialRoute: '/load',

      routes: {
        '/load': (context) => const Load_Page(),
        '/login': (context) => const Login_Page(),
        '/home': (context) => const Menu_page(),
        '/my-tickets': (context) => const Placeholder(),
        '/wallet': (context) => const Wallet_Page(),
        '/member': (context) => const ProfilePage(),
        '/topup': (context) => const Placeholder(),
        '/withdraw': (context) => const Placeholder(),
        '/purchase-history': (context) => const HistoryPage(),
        '/winning-history': (context) => const Placeholder(),
        '/buy': (context) => const Placeholder(),
        '/check-lottery': (context) => const Placeholder(),
        '/previous-results': (context) => const Placeholder(),
        '/personal': (context) => const PersonalPage(),
        '/register': (context) => Register_Page(),
      },
    );
  }
}
