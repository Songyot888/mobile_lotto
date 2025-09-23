import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/model/response/win_history_res.dart'; // ตรวจสอบว่า import ถูกต้อง
import 'package:mobile_lotto/page/buttom_nav.dart';

// [API SERVICE]
// แก้ไขฟังก์ชันให้ใช้ WinHistoryRes model ที่ถูกต้อง
Future<List<WinningHistory>> fetchWinningHistory(int userId) async {
  final response = await http.get(
    Uri.parse(
      'https://lotto-api-production.up.railway.app/api/User/winning-history/$userId',
    ),
  );

  if (response.statusCode == 200) {
    // ใช้ WinHistoryRes model เพื่อ parse ข้อมูล
    final winHistoryRes = WinHistoryRes.fromJson(json.decode(response.body));
    return winHistoryRes.winningHistory;
  } else {
    throw Exception('Failed to load winning history');
  }
}

class WinningHistoryPage extends StatefulWidget {
  const WinningHistoryPage({super.key});

  @override
  State<WinningHistoryPage> createState() => _WinningHistoryPageState();
}

class _WinningHistoryPageState extends State<WinningHistoryPage> {
  User? _user;
  late Future<List<WinningHistory>> _winningHistoryFuture;

  @override
  void initState() {
    super.initState();
    // เริ่มต้นด้วย Future ที่ว่างเปล่า
    _winningHistoryFuture = Future.value([]);
    _loadFromSession().then((_) {
      if (_user != null) {
        setState(() {
          _winningHistoryFuture = fetchWinningHistory(_user!.uid);
        });
      }
    });
  }

  Future<void> _loadFromSession() async {
    final u = await Session.getUser();
    if (mounted) {
      setState(() {
        _user = u;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF006064),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "ประวัติการถูกรางวัล",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 6, 180, 151),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "฿ ${NumberFormat("#,##0.00").format(_user?.balance ?? 0)}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF006064), Color(0xFF00838F), Color(0xFF006064)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: FutureBuilder<List<WinningHistory>>(
          future: _winningHistoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'เกิดข้อผิดพลาด',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, color: Colors.white70, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'ไม่พบประวัติการถูกรางวัล',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            final history = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: history.length,
              itemBuilder: (context, index) {
                return _WinningHistoryCard(item: history[index]);
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 3,
        routeNames: ['/home', '/my-tickets', '/wallet', '/member'],
        argumentsPerIndex: [_user, _user, _user, _user],
      ),
    );
  }
}

class _WinningHistoryCard extends StatelessWidget {
  final WinningHistory item;
  const _WinningHistoryCard({required this.item});

  String _extractPrizeNumber(String prizeText) {
    return prizeText.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy', 'th').format(date);
    } catch (e) {
      // หากไม่สามารถ parse วันที่ได้ ให้แสดงข้อมูลเดิม
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text(
            _formatDate(item.date),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 24.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF00838F).withOpacity(0.5),
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'เลขที่ถูกรางวัล:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    item.number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ถูก${item.prize}',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "฿ ${NumberFormat("#,##0").format(item.payout.toInt())}",
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
