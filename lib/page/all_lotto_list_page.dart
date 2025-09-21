import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:mobile_lotto/page/buttom_nav.dart';
import 'package:mobile_lotto/model/response/all_lottery_res_get.dart';

class AllLottoListPage extends StatefulWidget {
  const AllLottoListPage({super.key});

  @override
  State<AllLottoListPage> createState() => _AllLottoListPageState();
}

class _AllLottoListPageState extends State<AllLottoListPage> {
  int _tab = 0; // 0 = ยังไม่ขาย, 1 = ขายแล้ว
  bool _loading = false;

  List<AllLotteryResGet> _unsold = [];
  List<AllLotteryResGet> _sold = [];

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    try {
      // ยังไม่ขาย
      final r1 = await http.get(
        Uri.parse(
          "https://lotto-api-production.up.railway.app/api/User/unsold",
        ),
        headers: {"Content-Type": "application/json; charset=utf-8"},
      );
      if (r1.statusCode == 200) {
        _unsold = allLotteryResGetFromJson(r1.body);
      } else {
        log("unsold ${r1.statusCode}");
      }

      // ขายแล้ว (ถ้า endpoint ใช้ชื่ออื่น ให้เปลี่ยนตาม backend)
      try {
        final r2 = await http.get(
          Uri.parse(
            "https://lotto-api-production.up.railway.app/api/User/sold",
          ),
          headers: {"Content-Type": "application/json; charset=utf-8"},
        );
        if (r2.statusCode == 200) {
          _sold = allLotteryResGetFromJson(r2.body);
        } else {
          log("sold ${r2.statusCode}");
        }
      } catch (e) {
        // ถ้า backend ยังไม่มี endpoint นี้ จะปล่อย sold เป็นค่าว่าง
        log("fetch sold error $e");
      }
    } catch (e, st) {
      log("fetch all error", error: e, stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("โหลดข้อมูลไม่สำเร็จ"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _tab == 0 ? _unsold : _sold;

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
          child: Column(
            children: [
              // Header
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
                      "ล็อตเตอรี่ทั้งหมด",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              // แท็บตัวเลือก
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    _tabChip("ยังไม่ขาย", 0),
                    const SizedBox(width: 10),
                    _tabChip("ขายแล้ว", 1),
                  ],
                ),
              ),

              // รายการ
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : list.isEmpty
                    ? const Center(
                        child: Text(
                          "ไม่มีข้อมูล",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _lottoCard(
                          list[i].number.toString(),
                          isSold: _tab == 1,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNav(
        currentIndex: 0,
        routeNames: const ['/home', '/buy', '/wallet', '/member'],
      ),
    );
  }

  Widget _tabChip(String label, int idx) {
    final active = _tab == idx;
    return InkWell(
      onTap: () => setState(() => _tab = idx),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF006064) : Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _lottoCard(String number, {bool isSold = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE082),
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
          if (isSold) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00C4BA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "ขายแล้ว",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
