import 'package:flutter/material.dart';
import 'package:mobile_lotto/page/addlottery_page.dart';
import 'package:mobile_lotto/page/admin_page.dart';
import 'package:mobile_lotto/page/buy_lotto_page.dart';
import 'package:mobile_lotto/page/check_lottery_page.dart';
import 'package:mobile_lotto/page/editprofile_page.dart';
import 'package:mobile_lotto/page/load_page.dart';
import 'package:mobile_lotto/page/history_page.dart';
import 'package:mobile_lotto/page/login_page.dart';
import 'package:mobile_lotto/page/menu_page.dart';
import 'package:mobile_lotto/page/my_tickets_page.dart';
import 'package:mobile_lotto/page/personal_page.dart';
import 'package:mobile_lotto/page/profile_page.dart';
import 'package:mobile_lotto/page/register_page.dart';
import 'package:mobile_lotto/page/results_page.dart';
import 'package:mobile_lotto/page/wallet_page.dart';
import 'package:mobile_lotto/page/winning_history.dart';

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
        '/my-tickets': (context) => const MyTicketsPage(),
        '/wallet': (context) => const Wallet_Page(),
        '/member': (context) => const ProfilePage(),
        '/topup': (context) => const Placeholder(),
        '/withdraw': (context) => const Placeholder(),
        '/purchase-history': (context) => const HistoryPage(),
        '/winning-history': (context) => const WinningHistory(),
        '/buy': (context) => const BuyLottoPage(),
        '/check-lottery': (context) => const CheckLotteryPage(),
        '/previous-results': (context) => const ResultsPage(),
        '/personal': (context) => const PersonalPage(),
        '/register': (context) => Register_Page(),
        '/admin': (context) => const AdminPage(),
        '/edit': (context) => const EditprofilePage(),
        '/addlottery': (context) => const AddlotteryPage(),
      },
    );
  }
}
