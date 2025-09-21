import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_lotto/page/buttom_nav.dart';

String _spaced(String s, int padLen) {
  final clean = (s).replaceAll(RegExp(r'\D'), '').padLeft(padLen, '0');
  return clean.split('').join(' ');
}

Future<Map<String, String>> _fetchNumbers() async {
  final res = await http.get(
    Uri.parse("https://lotto-api-production.up.railway.app/api/User/result"),
    headers: {"Content-Type": "application/json; charset=utf-8"},
  );
  log("status: ${res.statusCode}");
  log(res.body);

  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw Exception("โหลดผลรางวัลไม่สำเร็จ (${res.statusCode})");
  }

  final jsonMap = json.decode(res.body) as Map<String, dynamic>;
  final List list = (jsonMap['result'] as List? ?? []);

  // เตรียมค่าเริ่มต้น
  String prize1 = "-", prize2 = "-", prize3 = "-", last3 = "-", last2 = "-";

  for (final item in list) {
    final rate = (item['payoutRate'] as num?)?.toInt();
    final amount = (item['amount'] ?? "").toString();

    switch (rate) {
      case 6000000:
        prize1 = _spaced(amount, 6);
        break;
      case 2000000:
        prize2 = _spaced(amount, 6);
        break;
      case 1000000:
        prize3 = _spaced(amount, 6);
        break;
      case 4000:
        last3 = _spaced(amount, 3);
        break;
      case 2000:
        last2 = _spaced(amount, 2);
        break;
    }
  }

  return {
    'prize1': prize1,
    'prize2': prize2,
    'prize3': prize3,
    'last3': last3,
    'last2': last2,
  };
}

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
              children: [
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
                    const Text(
                      "ออกรางวัล",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 12),

                // --------- ใช้ FutureBuilder แค่ส่วนตัวเลข ----------
                FutureBuilder<Map<String, String>>(
                  future: _fetchNumbers(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0097A7).withOpacity(0.55),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white70, width: 1.4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }

                    if (snap.hasError || !snap.hasData) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0097A7).withOpacity(0.55),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white70, width: 1.4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "โหลดผลรางวัลไม่สำเร็จ",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }

                    final numbers = snap.data!;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0097A7).withOpacity(0.55),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white70, width: 1.4),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "ประกาศผลรางวัล\n",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.5,
                              fontWeight: FontWeight.w800,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _PrizeSection(
                            title: "รางวัลที่ 1",
                            number: numbers['prize1'] ?? "-",
                            payout: "เงินรางวัล (6,000,000)",
                          ),
                          const SizedBox(height: 12),

                          _PrizeSection(
                            title: "รางวัลที่ 2",
                            number: numbers['prize2'] ?? "-",
                            payout: "เงินรางวัล (2,000,000)",
                          ),
                          const SizedBox(height: 12),

                          _PrizeSection(
                            title: "รางวัลที่ 3",
                            number: numbers['prize3'] ?? "-",
                            payout: "เงินรางวัล (1,000,000)",
                          ),
                          const SizedBox(height: 12),

                          _PrizeSection(
                            title: "เลขท้าย 3ตัว",
                            number: numbers['last3'] ?? "-",
                            payout: "เงินรางวัล (4,000)",
                          ),
                          const SizedBox(height: 12),

                          _PrizeSection(
                            title: "เลขท้าย 2ตัว",
                            number: numbers['last2'] ?? "-",
                            payout: "เงินรางวัล (2,000)",
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 0,
        routeNames: const ['/home', '/my-tickets', '/wallet', '/member'],
      ),
    );
  }
}

class _PrizeSection extends StatelessWidget {
  final String title;
  final String number;
  final String payout;

  const _PrizeSection({
    required this.title,
    required this.number,
    required this.payout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE082),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          payout,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
