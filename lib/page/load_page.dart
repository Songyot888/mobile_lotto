import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_lotto/page/login_page.dart';

class Load_Page extends StatefulWidget {
  const Load_Page({super.key});

  @override
  State<Load_Page> createState() => _Load_PageState();
}

class _Load_PageState extends State<Load_Page> {
  Color maroon = const Color(0xFF017E89);

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login_Page()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: maroon,
      body: Stack(
        children: [
          // โลโก้ + สโลแกนกลางจอ
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // โลโก้คำว่า Lotto888
                Image.asset('assets/lotto888.png', width: 500, height: 200),
                const Text(
                  'จ่ายหนัก จ่ายจริง ไม่จำกัด',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
          ),

          const Align(
            alignment: Alignment(0, 0.85),
            child: CircularProgressIndicator(
              color: Colors.white70,
              strokeWidth: 3,
            ),
          ),
        ],
      ),
    );
  }
}
