import 'package:flutter/material.dart';
import 'package:mobile_lotto/page/buttom_nav.dart'; // ใช้ BottomNav เดิมของคุณ
// ถ้าต้องส่ง user มากับ BottomNav ให้เพิ่มพารามิเตอร์ตามเวอร์ชันที่คุณใช้

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ พื้นหลังเต็มจอ
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
                // แถวบน: Back + Title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
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
                    // ถ้าต้องการไอคอนอื่น ๆ เพิ่มที่นี่ได้
                    const SizedBox(width: 8),
                  ],
                ),

                const SizedBox(height: 12),

                // ✅ กล่องผลรางวัลตรงกลาง
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0097A7).withOpacity(0.55), // teal อ่อนโปร่งแสง
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white70, width: 1.4),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    children: const [
                      Text(
                        "ผลรางวัลประจำงวด\n3 ก.ย 68",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.5,
                          fontWeight: FontWeight.w800,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 16),

                      // รางวัลที่ 1
                      _PrizeSection(
                        title: "รางวัลที่ 1",
                        number: "3 5 4 5 8 4",
                        payout: "เงินรางวัล (6,000,000)",
                      ),
                      SizedBox(height: 12),

                      // รางวัลที่ 2
                      _PrizeSection(
                        title: "รางวัลที่ 2",
                        number: "1 6 5 4 8 6",
                        payout: "เงินรางวัล (2,000,000)",
                      ),
                      SizedBox(height: 12),

                      // รางวัลที่ 3
                      _PrizeSection(
                        title: "รางวัลที่ 3",
                        number: "4 6 8 2 4 7",
                        payout: "เงินรางวัล (800,000)",
                      ),
                      SizedBox(height: 12),

                      // เลขท้าย 3 ตัว
                      _PrizeSection(
                        title: "เลขท้าย 3ตัว",
                        number: "5 8 4",
                        payout: "เงินรางวัล (80,000)",
                      ),
                      SizedBox(height: 12),

                      // เลขท้าย 2 ตัว
                      _PrizeSection(
                        title: "เลขท้าย 2ตัว",
                        number: "4 1",
                        payout: "เงินรางวัล (20,000)",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),

      // ✅ BottomNav — ตั้ง index ตามที่อยากให้ไฮไลท์ (เช่น 1 = หวยของฉัน หรือ 0 = หน้าแรก)
      bottomNavigationBar: BottomNav(
        currentIndex: 0,
        routeNames: const ['/home', '/buy', '/wallet', '/member'],
        // ถ้า BottomNav ของคุณรองรับ argumentsPerIndex:
        // argumentsPerIndex: [null, null, null, null],
      ),
    );
  }
}

class _PrizeSection extends StatelessWidget {
  final String title;
  final String number; // แสดงแบบแยกตัวเว้นวรรคเพื่อให้เหมือนดีไซน์
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
        // หัวข้อรางวัล
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),

        // แคปซูลเลข
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE082), // เหลืองอ่อน
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

        // ข้อความเงินรางวัล
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
