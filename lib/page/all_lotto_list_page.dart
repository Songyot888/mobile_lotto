import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:mobile_lotto/page/buttom_nav.dart';
import 'package:mobile_lotto/model/response/all_res.dart';

class AllLottoListPage extends StatefulWidget {
  const AllLottoListPage({super.key});

  @override
  State<AllLottoListPage> createState() => _AllLottoListPageState();
}

class _AllLottoListPageState extends State<AllLottoListPage> {
  int _tab = 0; // 0 = ยังไม่ขาย, 1 = ขายแล้ว
  bool _loading = false;

  List<AllLotteryResGet> _allLotteries = [];

  // แยกรายการตาม status
  List<AllLotteryResGet> get _unsoldLotteries {
    return _allLotteries.where((lottery) => lottery.status == true).toList();
  }

  List<AllLotteryResGet> get _soldLotteries {
    return _allLotteries.where((lottery) => lottery.status == false).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchAllLotteries();
  }

  Future<void> _fetchAllLotteries() async {
    setState(() => _loading = true);
    try {
      // ดึงข้อมูลสลากทั้งหมดจาก endpoint ใหม่
      final response = await http.get(
        Uri.parse(
          "https://lotto-api-production.up.railway.app/api/User/allLotto",
        ),
        headers: {"Content-Type": "application/json; charset=utf-8"},
      );

      if (response.statusCode == 200) {
        final allData = allLotteryResGetFromJson(response.body);

        if (mounted) {
          setState(() {
            _allLotteries = allData;
          });

          log("Total lotteries: ${_allLotteries.length}");
          log("Unsold (status=true): ${_unsoldLotteries.length}");
          log("Sold (status=false): ${_soldLotteries.length}");
        }
      } else {
        log("API Error: ${response.statusCode}");
        if (mounted) {
          _showErrorMessage("ไม่สามารถดึงข้อมูลได้ในขณะนี้");
        }
      }
    } catch (e, st) {
      log("Fetch error", error: e, stackTrace: st);
      if (mounted) {
        _showErrorMessage("เกิดข้อผิดพลาดในการเชื่อมต่อ");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _refreshData() async {
    await _fetchAllLotteries();
  }

  @override
  Widget build(BuildContext context) {
    final currentList = _tab == 0 ? _unsoldLotteries : _soldLotteries;

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
                    // ปุ่ม Refresh
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _loading ? null : _refreshData,
                    ),
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
                    _buildTabChip("ยังไม่ขาย (${_unsoldLotteries.length})", 0),
                    const SizedBox(width: 10),
                    _buildTabChip("ขายแล้ว (${_soldLotteries.length})", 1),
                  ],
                ),
              ),

              // รายการ
              Expanded(
                child: _loading
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              "กำลังโหลดข้อมูล...",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    : currentList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _tab == 0 ? Icons.inbox : Icons.check_circle,
                              color: Colors.white54,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _tab == 0
                                  ? "ไม่มีสลากที่ยังไม่ขาย"
                                  : "ไม่มีสลากที่ขายแล้ว",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _refreshData,
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white70,
                              ),
                              label: const Text(
                                "รีเฟรชข้อมูล",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshData,
                        backgroundColor: Colors.white,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: currentList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final lottery = currentList[i];
                            return _buildLottoCard(
                              lottery.number?.toString() ?? "------",
                              (lottery.price ?? 100).toInt(),
                              isSold: lottery.status == 0,
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, int index) {
    final isActive = _tab == index;
    return InkWell(
      onTap: () => setState(() => _tab = index),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF006064) : Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildLottoCard(String number, int price, {bool isSold = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30, width: 1.2),
      ),
      child: Row(
        children: [
          // หมายเลขสลาก
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: isSold
                    ? Colors.grey.withOpacity(0.6)
                    : const Color(0xFFFFE082),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  number,
                  style: TextStyle(
                    letterSpacing: 4,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: isSold ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ราคาและสถานะ
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isSold) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "ขายแล้ว",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C4BA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "วางขาย",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                "$price บาท",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
