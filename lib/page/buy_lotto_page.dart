import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/model/response/all_lottery_res_get.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/page/buttom_nav.dart';

class BuyLottoPage extends StatefulWidget {
  final User? user;
  const BuyLottoPage({super.key, this.user});

  @override
  State<BuyLottoPage> createState() => _BuyLottoPageState();
}

class _BuyLottoPageState extends State<BuyLottoPage> {
  User? _user;
  List<String> _suggestNumbers = [];

  @override
  void initState() {
    super.initState();
    _loadFromSession();
    _all(); // เรียก API ตัวอย่าง
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is User) {
      _user = args;
    }
    setState(() {});
  }

  Future<void> _loadFromSession() async {
    final u = await Session.getUser();
    if (!mounted) return;
    if (u != null) {
      setState(() {
        _user = u;
      });
    } else {
      setState(() {});
    }
  }

  Future<void> _all() async {
    var res = await http.post(
      Uri.parse("https://lotto-api-production.up.railway.app/api/User/unsold"),
      headers: {"Content-Type": "application/json; charset=utf-8"},
    );
    if (res.statusCode != 200) {
      log("Error fetching data: ${res.statusCode}");
      return;
    } else {
      final list = List<String>.from(jsonDecode(res.body));
      setState(() {
        _suggestNumbers = list;
      });
    }
  }

  // ไม่ต้องมีโหมดแล้ว เพราะให้โชว์สีคงที่ตลอด
  final List<String> _modes = ["3ตัวหน้า", "3ตัวหลัง", "2ตัว"];

  @override
  Widget build(BuildContext context) {
    final balance = widget.user?.balance?.toDouble() ?? 9999.99;

    return Scaffold(
      body: Container(
        width: double.infinity, // ✅ เต็มความกว้าง
        height: double.infinity, // ✅ เต็มความสูง
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF006064), Color(0xFF00838F), Color(0xFF006064)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // แถวบน: Back + Title + Balance
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        "ซื้อสลากกินแบ่ง",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _BalancePill(amount: _user?.balance ?? 0),
                  ],
                ),

                const SizedBox(height: 18),

                // หัวข้อ
                const Text(
                  "ค้นหาเลขเด็ด\nงวดวันที่ 13 มิ.ย 2565",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // ✅ ปุ่มโหมด "โชว์สีตลอด" (ไม่โต้ตอบ)
                Wrap(
                  spacing: 10,
                  children: _modes.map((label) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white, // โชว์เป็น selected ตลอด
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFF006064), // สีตัวอักษร teal เข้ม
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                const Text(
                  "เลขแนะนำประจำวัน\nสลากกินแบ่งรัฐบาล",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // การ์ดเลขแนะนำ
                Column(
                  children: _suggestNumbers.map((num) {
                    return _SuggestionCard(
                      number: num.toString(),
                      onBuy: () {
                        // TODO: ไปหน้ากรอกจำนวน/ยืนยันรายการ
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('กดซื้อเลข $num (ตัวอย่าง)')),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),

      // BottomNav: ตั้ง index = 1 (แท็บ "หวยของฉัน")
      bottomNavigationBar: BottomNav(
        currentIndex: 1,
        routeNames: const ['/home', '/buy', '/wallet', '/member'],
        // ถ้ามี argumentsPerIndex ใน BottomNav ของคุณ ให้ส่ง user ต่อไปได้
        // argumentsPerIndex: [widget.user, widget.user, widget.user, widget.user],
      ),
    );
  }
}

class _BalancePill extends StatelessWidget {
  final double amount;
  const _BalancePill({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white70, width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            amount.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String number;
  final VoidCallback onBuy;
  const _SuggestionCard({required this.number, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30, width: 1.2),
      ),
      child: Row(
        children: [
          // กล่องเลข
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE082), // เหลืองอ่อนคล้ายภาพ
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    letterSpacing: 4,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ปุ่มซื้อเลย
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: onBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF00C4BA,
                  ), // ✅ เขียวอมฟ้าตามภาพ
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "ซื้อเลย",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text("100 บาท", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}
