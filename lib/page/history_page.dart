import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/page/buttom_nav.dart';

// === เพิ่ม import ของ req/res ตามที่คุณสร้างไว้ ===
import 'package:mobile_lotto/model/request/history_buy_req.dart';
import 'package:mobile_lotto/model/response/history_buy_res_post.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  User? _user;

  bool _loading = false;
  String? _error;
  List<HistoryBuyResPost> _items = [];

  @override
  void initState() {
    super.initState();
    _loadFromSession();
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
      setState(() => _user = u);
      await _fetchHistory(); // โหลดรายการทันทีเมื่อได้ user
    } else {
      setState(() {});
    }
  }

  Future<void> _fetchHistory() async {
    if (_user == null) return;

    // ตรวจสอบ uid ก่อนส่ง
    final uid = _user?.uid;
    if (uid == null) {
      setState(() {
        _error = "ไม่พบ memberId ของผู้ใช้";
        _items = [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // แก้ไข: จัดการ uid ให้เป็น int
      int memberId;
      if (uid is int) {
        memberId = uid;
      } else if (uid is String) {
        memberId = int.tryParse(uid as String) ?? 0;
        if (memberId == 0) {
          setState(() {
            _error = "รูปแบบ memberId ไม่ถูกต้อง";
            _items = [];
          });
          return;
        }
      } else {
        setState(() {
          _error = "ประเภทข้อมูล memberId ไม่ถูกต้อง";
          _items = [];
        });
        return;
      }

      final req = HistoryBuyReq(memberId: memberId);

      final resp = await http.post(
        Uri.parse(
          "https://lotto-api-production.up.railway.app/api/User/TxnLotto",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(req.toJson()),
      );

      if (resp.statusCode == 200) {
        // เพิ่มการตรวจสอบ response body
        final responseBody = resp.body.trim();
        if (responseBody.isEmpty) {
          setState(() {
            _items = [];
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

          // จัดเรียงใหม่ (ล่าสุดอยู่บน) - ตรวจสอบ null ก่อน
          allData.sort((a, b) {
            final dateA = a.dateIso;
            final dateB = b.dateIso;

            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;

            return dateB.compareTo(dateA);
          });

          setState(() {
            _items = allData;
          });
        } catch (parseError) {
          setState(() {
            _error = "เกิดข้อผิดพลาดในการแปลงข้อมูล: $parseError";
            _items = [];
          });
        }
      } else {
        setState(() {
          _error =
              'เกิดข้อผิดพลาด (${resp.statusCode}) : ${resp.reasonPhrase ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _fetchHistory,
                child: const Text('ลองอีกครั้ง'),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text(
          "ยังไม่มีประวัติการซื้อ",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHistory,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
        itemBuilder: (_, i) {
          final it = _items[i];

          // ป้องกัน null values
          final displayNumber = it.number?.trim() ?? '-';
          final displayDateTh = it.dateTh?.trim() ?? '—';

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.confirmation_number),
              ),
              title: Text(
                "เลข: $displayNumber",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text("งวด: $displayDateTh"),
              trailing: Text(
                _formatShort(it.dateIso),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: _items.length,
      ),
    );
  }

  String _formatShort(DateTime? dt) {
    // ป้องกัน null DateTime
    if (dt == null) return '—';

    // รูปแบบย่อเช่น 21/09/25 14:30
    final d = dt.toLocal();
    final two = (int x) => x.toString().padLeft(2, '0');
    final yy = (d.year % 100).toString().padLeft(2, '0');
    return "${two(d.day)}/${two(d.month)}/$yy ${two(d.hour)}:${two(d.minute)}";
    // ถ้าต้องการใช้ dateTh ที่มาจาก API ก็สามารถใช้ it.dateTh แทนได้
  }

  @override
  Widget build(BuildContext context) {
    final balanceStr = (_user?.balance ?? 0).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF006064),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "ประวัติการซื้อ",
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
              "฿ $balanceStr",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF006064), Color(0xFF00838F), Color(0xFF006064)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: _buildBody(),
      ),

      bottomNavigationBar: BottomNav(
        currentIndex: 3,
        routeNames: ['/home', '/my-tickets', '/wallet', '/member'],
        argumentsPerIndex: [_user, _user, _user, _user],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _fetchHistory,
        icon: const Icon(Icons.refresh),
        label: const Text('รีเฟรช'),
      ),
    );
  }
}
