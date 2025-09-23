import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ⬇️ ปรับให้ตรงกับโปรเจกต์ของคุณ
import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/model/response/ran_result_res_post.dart';

class RandomDrawPage extends StatefulWidget {
  const RandomDrawPage({super.key});

  @override
  State<RandomDrawPage> createState() => _RandomDrawPageState();
}

class DrawResult {
  final DateTime at;
  final String prize1;
  final String prize2;
  final String prize3;
  final String last3;
  final String last2;

  DrawResult({
    required this.at,
    required this.prize1,
    required this.prize2,
    required this.prize3,
    required this.last3,
    required this.last2,
  });
}

class _RandomDrawPageState extends State<RandomDrawPage> {
  // หมายเลขที่จะแสดง (รอบปัจจุบัน)
  String prize1 = "------";
  String prize2 = "------";
  String prize3 = "------";
  String last3 = "---";
  String last2 = "--";

  // เงินรางวัลที่แสดง (format แล้ว)
  String payout1 = "-";
  String payout2 = "-";
  String payout3 = "-";
  String payoutLast3Each = "-";
  String payoutLast2Each = "-";

  bool _loading = false;
  String? _error;

  User? _user; // ผู้ใช้ที่ล็อกอิน

  // ประวัติเลขที่สุ่มในหน้านี้ (ล่าสุดอยู่ index 0)
  final List<DrawResult> _history = [];

  @override
  void initState() {
    super.initState();
    _loadAuthThenFetch();
  }

  /// helper: ดึง uid จากโมเดล User (ลองทั้ง uid และ id)
  int? _getUid(User? u) {
    if (u == null) return null;
    try {
      final v = (u as dynamic).uid;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
    } catch (_) {}
    try {
      final v = (u as dynamic).id;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
    } catch (_) {}
    try {
      final v = (u as dynamic).memberId;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
    } catch (_) {}
    return null;
  }

  Future<void> _loadAuthThenFetch() async {
    setState(() => _loading = true);
    try {
      _user = await Session.getUser();

      final uid = _getUid(_user);
      if (uid == null) {
        throw Exception(
          "ยังไม่ได้ล็อกอิน หรือไม่พบ uid/id ของผู้ใช้ใน Session",
        );
      }
      await _fetchRandom(); // จะ resolve uid จาก _user ภายใน
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  /// ยิง API ไปสุ่มผลจากเซิร์ฟเวอร์ และอัปเดตหน้าจอ + เก็บประวัติ
  Future<void> _fetchRandom({int? uid}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final finalUid = uid ?? _getUid(_user);
      if (finalUid == null) {
        throw Exception("ไม่พบ uid/id ผู้ใช้");
      }

      // 1) ลองแบบ JSON ก่อน
      Future<http.Response> postJson() => http.post(
        Uri.parse(
          "https://lotto-api-production.up.railway.app/api/Admin/result-lottery",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"uid": finalUid}),
      );

      // 2) ถ้า 415 ให้ลองแบบ x-www-form-urlencoded
      Future<http.Response> postForm() => http.post(
        Uri.parse(
          "https://lotto-api-production.up.railway.app/api/Admin/result-lottery",
        ),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"uid": finalUid.toString()},
        encoding: Encoding.getByName('utf-8'),
      );

      // 3) ถ้า 415 อีก ลองส่ง POST body ว่าง (ไม่ใส่ Content-Type)
      Future<http.Response> postEmpty() => http.post(
        Uri.parse(
          "https://lotto-api-production.up.railway.app/api/Admin/result-lottery",
        ),
      );

      // 4) เผื่อปลายทางเป็น GET
      Future<http.Response> getCall() => http.get(
        Uri.parse(
          "https://lotto-api-production.up.railway.app/api/Admin/result-lottery?uid=$finalUid",
        ),
      );

      http.Response resp = await postJson();
      if (resp.statusCode == 415) {
        resp = await postForm();
      }
      if (resp.statusCode == 415) {
        resp = await postEmpty();
      }
      if (resp.statusCode == 415) {
        resp = await getCall();
      }

      if (resp.statusCode != 200) {
        // โชว์ข้อความจากเซิร์ฟเวอร์เพื่อ debug ง่าย
        String serverMsg;
        try {
          final j = jsonDecode(resp.body);
          serverMsg = j is Map && j["message"] != null
              ? j["message"].toString()
              : resp.body;
        } catch (_) {
          serverMsg = resp.body;
        }
        throw Exception("HTTP ${resp.statusCode}: $serverMsg");
      }

      final data = ranResultResPostFromJson(resp.body);

      final curPrize1 = data.prizes.first.number;
      final curPrize2 = data.prizes.second.number;
      final curPrize3 = data.prizes.third.number;
      final curLast3 = data.prizes.last3.last3;
      final curLast2 = data.prizes.last2.last2;

      setState(() {
        prize1 = curPrize1;
        prize2 = curPrize2;
        prize3 = curPrize3;
        last3 = curLast3;
        last2 = curLast2;

        payout1 = _money(data.prizes.first.payout);
        payout2 = _money(data.prizes.second.payout);
        payout3 = _money(data.prizes.third.payout);
        payoutLast3Each = _money(data.prizes.last3.payoutEach);
        payoutLast2Each = _money(data.prizes.last2.payoutEach);

        // (ถ้าคุณมี _history อยู่แล้ว ก็ insert ลงประวัติได้ที่นี่)
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  /// ฟอร์แมตตัวเลขเงินแบบง่าย ๆ (1,234,567)
  String _money(num n) {
    final s = n.toString();
    final rgx = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(rgx, (m) => '${m[1]},');
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

  Widget _historyList() {
    if (_history.isEmpty) {
      return Text(
        "ยังไม่มีการสุ่มในหน้านี้",
        style: TextStyle(color: Colors.white.withOpacity(0.85)),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white24),
      itemBuilder: (context, i) {
        final h = _history[i];
        final t = TimeOfDay.fromDateTime(h.at);
        final hh = t.hour.toString().padLeft(2, '0');
        final mm = t.minute.toString().padLeft(2, '0');
        final ts =
            "${h.at.year}-${h.at.month.toString().padLeft(2, '0')}-${h.at.day.toString().padLeft(2, '0')} $hh:$mm";

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                runSpacing: 4,
                spacing: 8,
                children: [
                  _chip("ที่1", h.prize1),
                  _chip("ที่2", h.prize2),
                  _chip("ที่3", h.prize3),
                  _chip("ท้าย3", h.last3),
                  _chip("ท้าย2", h.last2),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              ts,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        );
      },
    );
  }

  Widget _chip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : _error != null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  "เกิดข้อผิดพลาด\n${_error!}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _fetchRandom(),
                  child: const Text(
                    "ลองใหม่",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // การ์ดผลรางวัลปัจจุบัน
                Container(
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
                        "ผลรางวัลประจำงวด",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _line("รางวัลที่ 1", prize1, payout1),
                      _line("รางวัลที่ 2", prize2, payout2),
                      _line("รางวัลที่ 3", prize3, payout3),
                      _line("เลขท้าย 3 ตัว", last3, payoutLast3Each),
                      _line("เลขท้าย 2 ตัว", last2, payoutLast2Each),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ประวัติเลขที่สุ่มทั้งหมด
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "เลขที่สุ่มทั้งหมด (ในหน้านี้)",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _historyList(),
                    ],
                  ),
                ),
              ],
            ),
          );

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
                    TextButton(
                      onPressed: () =>
                          _fetchRandom(), // ยิง API ใหม่เพื่อสุ่มอีกครั้ง
                      child: const Text(
                        "สุ่มใหม่",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // การ์ดกลาง/ส่วนเนื้อหา
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
