import 'package:flutter/material.dart';
import 'package:mobile_lotto/page/load_page.dart';
import 'package:mobile_lotto/page/history_page.dart';
import 'package:mobile_lotto/page/login_page.dart';
import 'package:mobile_lotto/page/menu_page.dart';
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

      // 👇 เลือกหน้าเริ่มต้น
      // initialRoute: '/login',
      initialRoute: '/login',

      routes: {
        '/login': (context) => const Login_Page(),
        '/home': (context) => const Menu_page(),
        '/my-tickets': (context) => const Placeholder(), // TODO: ใส่หน้าจริง
        '/wallet': (context) => const Wallet_Page(),
        '/member': (context) => const Placeholder(), // TODO: ใส่หน้าจริง
        '/topup': (context) => const Placeholder(), // TODO
        '/withdraw': (context) => const Placeholder(), // TODO
        '/purchase-history': (context) => const HistoryPage(), // TODO
        '/winning-history': (context) => const Placeholder(), // TODO
        '/buy': (context) => const Placeholder(), // TODO
        '/check-lottery': (context) => const Placeholder(), // TODO
        '/previous-results': (context) => const Placeholder(), // TODO
      },
    );
  }
}
