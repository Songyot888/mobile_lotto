import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile_lotto/page/buttom_nav.dart';

class RandomDrawPage extends StatefulWidget {
  const RandomDrawPage({super.key});

  @override
  State<RandomDrawPage> createState() => _RandomDrawPageState();
}

class _RandomDrawPageState extends State<RandomDrawPage> {
  String prize1 = "------";
  String prize2 = "------";
  String prize3 = "------";
  String last3 = "---";
  String last2 = "--";

  @override
  void initState() {
    super.initState();
    _roll(); // สุ่มตอนเข้าเพจ
  }

  // สุ่มตัวเลขตามรูปแบบ
  void _roll() {
    final rnd = Random();
    setState(() {
      prize1 = (rnd.nextInt(1000000)).toString().padLeft(6, '0');
      prize2 = (rnd.nextInt(1000000)).toString().padLeft(6, '0');
      prize3 = (rnd.nextInt(1000000)).toString().padLeft(6, '0');
      last3 = (rnd.nextInt(1000)).toString().padLeft(3, '0');
      last2 = (rnd.nextInt(100)).toString().padLeft(2, '0');
    });
  }

  Widget _pillNumber(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 4,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _line(String title, String number, String money) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // หัวข้อรางวัล
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _pillNumber(number),
          const SizedBox(height: 6),
          Text(
            "เงินรางวัล ($money)",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // พื้นหลังเต็มจอ
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
          child: Column(
            children: [
              // แถวหัวข้อ
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "สุ่มผลรางวัล",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    // ปุ่มสุ่มใหม่ (ไม่อยู่ในภาพ แต่มีไว้ให้ใช้งานสะดวก)
                    TextButton(
                      onPressed: _roll,
                      child: const Text(
                        "สุ่มใหม่",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // การ์ดกลาง
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white30, width: 1.4),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "ผลรางวัลประจำงวด\n3 ก.ย 68",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            height: 1.3,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _line("รางวัลที่ 1", prize1, "6,000,000"),
                        _line("รางวัลที่ 2", prize2, "1,000,000"),
                        _line("รางวัลที่ 3", prize3, "800,000"),
                        _line("เลขท้าย 3ตัว", last3, "80,000"),
                        _line("เลขท้าย 2ตัว", last2, "20,000"),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // แถบเมนูล่าง
      
    );
  }
}
