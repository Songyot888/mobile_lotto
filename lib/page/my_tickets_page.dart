import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ⬇️ ปรับ path ให้ตรงโปรเจกต์ของคุณ
import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/page/buttom_nav.dart';

// ⬇️ import models req/res ของคุณ (ตามไฟล์จริงในโปรเจกต์)
import 'package:mobile_lotto/model/request/history_buy_req.dart';
import 'package:mobile_lotto/model/response/history_buy_res_post.dart';

class MyTicketsPage extends StatefulWidget {
  final User? user;
  const MyTicketsPage({super.key, this.user});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  User? _user;
  VoidCallback? _userListener;

  // --- state สำหรับโหลด/ผิดพลาด/ข้อมูล ---
  bool _loading = false;
  String? _error;
  List<HistoryBuyResPost> _history = [];

  double get balance =>
      Session.currentUser.value?.balance ??
      _user?.balance ??
      widget.user?.balance ??
      0.0;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _userListener = () {
      if (!mounted) return;
      setState(() {
        _user = Session.currentUser.value;
      });
    };
    Session.currentUser.addListener(_userListener!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is User) {
      _user = args;
    }
  }

  Future<void> _bootstrap() async {
    // 1) โหลด user จาก session (ถ้ามี)
    await _loadFromSession();

    // 2) ดึง history ต่อเมื่อมี memberId
    if (_user?.uid != null) {
      await _fetchHistory();
    }
  }

  Future<void> _loadFromSession() async {
    final u = await Session.getUser();
    if (!mounted) return;
    setState(() {
      _user = u ?? widget.user;
    });
  }

  Future<void> _fetchHistory() async {
    // เพิ่มการตรวจสอบ uid แบบชัดเจนมากขึ้น
    final uid = _user?.uid;
    if (uid == null) {
      setState(() {
        _error = "ไม่พบ memberId ของผู้ใช้";
        _history = [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // แก้ไข: cast uid เป็น int (ถ้าแน่ใจว่าเป็น int)
      final req = HistoryBuyReq(memberId: uid);
      final url = Uri.parse(
        "https://lotto-api-production.up.railway.app/api/User/TxnLotto",
      );

      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(req.toJson()),
      );

      if (resp.statusCode == 200) {
        // เพิ่มการตรวจสอบ response body
        final responseBody = resp.body.trim();
        if (responseBody.isEmpty) {
          setState(() {
            _history = [];
            _error = null;
          });
          return;
        }

        try {
          // แปลง JSON เป็น list แล้วกรองเฉพาะรายการที่สมบูรณ์
          final jsonList = json.decode(responseBody) as List;
          final List<HistoryBuyResPost> allData = [];

          for (var item in jsonList) {
            try {
              // ตรวจสอบว่ามีข้อมูลสำคัญหรือไม่
              if (item != null &&
                  item is Map<String, dynamic> &&
                  item['number'] != null &&
                  item['number'].toString().trim().isNotEmpty) {
                final historyItem = HistoryBuyResPost.fromJson(item);
                allData.add(historyItem);
              }
            } catch (itemError) {
              // ข้าม item ที่ parse ไม่ได้
              print('Skip invalid item: $itemError');
              continue;
            }
          }

          final List<HistoryBuyResPost> data = allData;

          setState(() {
            _history = data;
            _error = null;
          });
        } catch (parseError) {
          setState(() {
            _error = "เกิดข้อผิดพลาดในการแปลงข้อมูล: $parseError";
            _history = [];
          });
        }
      } else {
        setState(() {
          _error =
              "เรียก API ล้มเหลว (${resp.statusCode}) : ${resp.reasonPhrase ?? 'Unknown error'}";
          _history = [];
        });
      }
    } catch (e) {
      setState(() {
        _error = "เกิดข้อผิดพลาด: $e";
        _history = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await _fetchHistory();
  }

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
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            displacement: 24,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                          "หวยของฉัน",
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
                  const SizedBox(height: 12),

                  // --- ส่วนเนื้อหา: loading / error / empty / list ---
                  if (_loading) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ] else if (_error != null) ...[
                    _ErrorBanner(
                      message: _error!,
                      onRetry: _fetchHistory, // แก้ไข: ไม่ต้องใช้ closure
                    ),
                  ] else if (_history.isEmpty) ...[
                    const _EmptyState(),
                  ] else ...[
                    // แปลง history เป็นการ์ด (กัน null ทุกช่อง)
                    Column(
                      children: _history.map((h) {
                        // ปรับปรุงการจัดการ null สำหรับ number
                        final String displayNumber = h.number?.trim() ?? '-';

                        // ปรับปรุงการจัดการ null สำหรับ date
                        String displayDate = '—';
                        if (h.dateTh != null && h.dateTh!.trim().isNotEmpty) {
                          displayDate = h.dateTh!.trim();
                        } else if (h.dateIso != null) {
                          try {
                            displayDate = h.dateIso!.toIso8601String();
                          } catch (e) {
                            displayDate = '—';
                          }
                        }

                        return _TicketCard(
                          number: displayNumber,
                          subtitleRight: displayDate,
                          status: "สำเร็จ",
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),

      // BottomNav ของโปรเจกต์คุณ
      bottomNavigationBar: BottomNav(
        currentIndex: 1,
        routeNames: const ['/home', '/buy', '/wallet', '/member'],
      ),
    );
  }

  @override
  void dispose() {
    if (_userListener != null) {
      Session.currentUser.removeListener(_userListener!);
    }
    super.dispose();
  }
}

// ---------------- Widgets ย่อย ----------------

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

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "เกิดข้อผิดพลาด",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onRetry,
              child: const Text(
                "ลองใหม่",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 28),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30, width: 1.2),
      ),
      child: const Center(
        child: Text(
          "ยังไม่มีประวัติการซื้อ",
          style: TextStyle(color: Colors.white70, fontSize: 14.5),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final String number; // แก้ไข: ไม่ยอมรับ null แล้ว
  final String status;
  final String subtitleRight; // แก้ไข: ไม่ยอมรับ null แล้ว

  const _TicketCard({
    required this.number,
    required this.status,
    required this.subtitleRight, // แก้ไข: required แล้ว
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // กล่องเลขเหลือง
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
          const SizedBox(width: 12),

          // วันที่/สถานะ
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                subtitleRight,
                style: const TextStyle(color: Colors.white70, fontSize: 12.5),
              ),
              const SizedBox(height: 10),
              Text(
                status,
                style: const TextStyle(
                  color: Color(0xFF00C4BA), // เขียวอมฟ้า "สำเร็จ"
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
