import 'package:flutter/material.dart';
import 'package:mobile_lotto/page/login_page.dart';
import 'package:mobile_lotto/page/menu_page.dart';
import 'package:mobile_lotto/page/register_page.dart';
import 'package:mobile_lotto/page/register_page.dart';
import 'package:mobile_lotto/page/wallet_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lotto888',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 77, 1, 255),
        ),
      ),
      home: Login_Page(),
    );
  }
}
