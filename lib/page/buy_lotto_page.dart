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
  List<AllLotteryResGet> allLotteryresget = [];

  // ✅ โหมดที่เลือก: 0=3ตัวหน้า, 1=3ตัวหลัง, 2=2ตัว
  int _mode = 0;
  final List<String> _modes = ["3ตัวหน้า", "3ตัวหลัง", "2ตัว"];

  @override
  void initState() {
    super.initState();
    _loadFromSession();
    _all();
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
    try {
      final res = await http.get(
        Uri.parse(
          "https://lotto-api-production.up.railway.app/api/User/unsold",
        ),
        headers: {"Content-Type": "application/json; charset=utf-8"},
      );
      log("ALL status: ${res.statusCode}");
      if (res.statusCode == 200) {
        log("ALL body  : ${res.body}");
        final parsed = allLotteryResGetFromJson(res.body);
        if (!mounted) return;
        setState(() {
          allLotteryresget = parsed;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่สามารถดึงข้อมูลได้ในขณะนี้ กรุณาลองใหม่อีกครั้ง'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, st) {
      log("Error on _all()", error: e, stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ คืนเลขตามโหมดที่เลือก
  String shortByMode(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return "-";
    if (_mode == 0) {
      // 3 ตัวหน้า
      return s.length >= 3 ? s.substring(0, 3) : s;
    } else if (_mode == 1) {
      // 3 ตัวหลัง
      return s.length >= 3 ? s.substring(s.length - 3) : s;
    } else {
      // 2 ตัวท้าย
      return s.length >= 2 ? s.substring(s.length - 2) : s;
    }
  }

  // ✅ ปุ่มโหมด
  Widget _modePill(String label, int index) {
    final active = _mode == index;
    return InkWell(
      onTap: () => setState(() => _mode = index),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF006064) : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = _user?.balance?.toDouble() ?? 9999.99;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                    _BalancePill(amount: balance),
                  ],
                ),

                const SizedBox(height: 18),

                const Text(
                  "ค้นหาเลขเด็ด\nงวดวันที่ 13 มิ.ย 2565",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // ✅ ปุ่มโหมด (กดสลับได้)
                Wrap(
                  spacing: 10,
                  children: List.generate(
                    _modes.length,
                    (i) => _modePill(_modes[i], i),
                  ),
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
                const SizedBox(height: 8),

                // ✅ จำนวนทั้งหมด
                Text(
                  "พบทั้งหมด ${allLotteryresget.length} รายการ",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),

                // ✅ การ์ดเลขแนะนำ
                Column(
                  children: allLotteryresget.map((e) {
                    final raw = (e.number).toString();
                    final short = shortByMode(raw);
                    final modeName = _modes[_mode];

                    return _SuggestionCard(
                      rawNumber: raw,
                      shortNumber: short,
                      modeName: modeName,
                      onBuy: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'กดซื้อ $modeName: $short (จากเลข $raw)',
                            ),
                          ),
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

      bottomNavigationBar: BottomNav(
        currentIndex: 1,
        routeNames: const ['/home', '/buy', '/wallet', '/member'],
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
  final String rawNumber; // เลขเต็มจาก API
  final String shortNumber; // เลขตามโหมด
  final String modeName; // 3ตัวหน้า / 3ตัวหลัง / 2ตัว
  final VoidCallback onBuy;

  const _SuggestionCard({
    required this.rawNumber,
    required this.shortNumber,
    required this.modeName,
    required this.onBuy,
  });

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
          // 🔸 เลขเต็ม
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE082),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      rawNumber,
                      style: const TextStyle(
                        letterSpacing: 4,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                // 🔸 ป้ายโหมด
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C4BA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "$modeName: $shortNumber",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10, // ✅ ลดขนาดฟอนต์ลงจาก 12 → 10
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 🔸 ปุ่มซื้อ
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: onBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C4BA),
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
