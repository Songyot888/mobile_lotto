import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_lotto/core/session.dart';

import 'package:mobile_lotto/model/request/buy_lotterry_req.dart';
import 'package:mobile_lotto/model/response/buy_lottery_res_post.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/model/response/all_lottery_res_get.dart';
import 'package:mobile_lotto/page/buttom_nav.dart';

// API Endpoints
const _unsoldEndpoint =
    "https://lotto-api-production.up.railway.app/api/User/unsold";
const _buyEndpoint = "https://lotto-api-production.up.railway.app/api/User/buy";

class SearchNumberPage extends StatefulWidget {
  final User? user;
  const SearchNumberPage({super.key, this.user});

  @override
  State<SearchNumberPage> createState() => _SearchNumberPageState();
}

class _SearchNumberPageState extends State<SearchNumberPage> {
  final TextEditingController _numberCtrl = TextEditingController();
  User? _user;

  // 0=3ตัวหน้า, 1=3ตัวหลัง, 2=2ตัว
  int _mode = 0;
  final List<String> _modes = ["3ตัวหน้า", "3ตัวหลัง", "2ตัว"];

  bool _loading = false;
  List<AllLotteryResGet> _all = [];
  List<AllLotteryResGet> _results = [];

  // สำหรับการซื้อ
  int? _buyingId;
  double? _walletOverride;

  // หา memberId จากโมเดล User
  int? get _memberId => _user?.uid;

  @override
  void dispose() {
    _numberCtrl.dispose();
    super.dispose();
  }

  void _clear() {
    setState(() {
      _numberCtrl.clear();
      _results = [];
    });
  }

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
    try {
      final u = await Session.getUser();
      if (mounted && u != null) {
        setState(() => _user = u);
      }
    } catch (e) {
      log('Error loading user from session: $e');
    }
  }

  Future<void> _loadUnsold() async {
    if (_all.isNotEmpty) return;
    try {
      setState(() => _loading = true);
      final res = await http.get(
        Uri.parse(_unsoldEndpoint),
        headers: {"Content-Type": "application/json; charset=utf-8"},
      );
      if (res.statusCode == 200) {
        _all = allLotteryResGetFromJson(res.body);
      } else {
        throw Exception("API ${res.statusCode}");
      }
    } catch (e, st) {
      log("UNSOLD error", error: e, stackTrace: st);
      if (mounted) {
        _showErrorSnackBar("ดึงข้อมูลเลขไม่สำเร็จ");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String shortByMode(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return "-";

    switch (_mode) {
      case 0: // 3 ตัวหน้า
        return s.length >= 3 ? s.substring(0, 3) : s;
      case 1: // 3 ตัวหลัง
        return s.length >= 3 ? s.substring(s.length - 3) : s;
      default: // 2 ตัวท้าย
        return s.length >= 2 ? s.substring(s.length - 2) : s;
    }
  }

  bool _matchByMode(String full, String query) {
    final q = query.trim();
    if (q.isEmpty) return true;
    if (_mode == 0) return full.startsWith(q); // 3 หน้า
    if (_mode == 1) return full.endsWith(q); // 3 หลัง
    return full.endsWith(q); // 2 ตัวท้าย
  }

  Future<void> _search() async {
    final s = _numberCtrl.text.trim();
    if (s.isEmpty) {
      _showErrorSnackBar('กรุณากรอกเลขที่ต้องการค้นหา');
      return;
    }

    await _loadUnsold();
    final filtered = _all
        .where((e) => _matchByMode(e.number.toString(), s))
        .toList();

    if (!mounted) return;
    setState(() => _results = filtered);

    if (filtered.isEmpty) {
      _showErrorSnackBar('ไม่พบเลขที่ต้องการ');
    }
  }

  // สุ่มเลขตามโหมดที่เลือก
  void _random() {
    final len = _mode == 2 ? 2 : 3; // โหมด 2 => 2 หลัก, อื่นๆ 3 หลัก
    final rnd = (DateTime.now().microsecondsSinceEpoch % (pow(10, len) as int))
        .toString()
        .padLeft(len, '0');
    setState(() => _numberCtrl.text = rnd);
  }

  // ซื้อสลากผ่าน API
  Future<void> _buyLottery(int lotteryId) async {
    final currentMemberId = _memberId;

    if (currentMemberId == null) {
      _showErrorSnackBar("กรุณาเข้าสู่ระบบก่อนทำรายการ");
      return;
    }

    setState(() => _buyingId = lotteryId);

    try {
      final req = BuyLotterryReq(
        memberId: currentMemberId,
        lotteryId: lotteryId,
      );

      final response = await http.post(
        Uri.parse(_buyEndpoint),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Accept": "application/json",
        },
        body: json.encode(req.toJson()),
      );

      if (response.statusCode == 200) {
        final data = BuyLotteryResPost.fromJson(json.decode(response.body));

        setState(() {
          _walletOverride = data.wallet.toDouble();
          // ลบรายการที่ซื้อแล้วออกจากลิสต์
          _results.removeWhere((x) => x.lid == lotteryId);
          _all.removeWhere((x) => x.lid == lotteryId);
        });

        // แสดงข้อความสำเร็จ
        await _showSuccessDialog(data);
      } else {
        String errorMessage = await _parseErrorMessage(response);
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      log("Error buying lottery: $e");
      _showErrorSnackBar(_getNetworkErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _buyingId = null);
      }
    }
  }

  Future<String> _parseErrorMessage(http.Response response) async {
    try {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse is Map<String, dynamic>) {
        return jsonResponse["message"]?.toString() ??
            jsonResponse["error"]?.toString() ??
            "การซื้อไม่สำเร็จ";
      }
    } catch (_) {}

    switch (response.statusCode) {
      case 400:
        return "ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง";
      case 401:
        return "ไม่มีสิทธิ์เข้าถึง กรุณาเข้าสู่ระบบใหม่";
      case 404:
        return "ไม่พบข้อมูลที่ต้องการ";
      case 500:
        return "เซิร์ฟเวอร์มีปัญหา กรุณาลองใหม่อีกครั้ง";
      default:
        return "เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง";
    }
  }

  String _getNetworkErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception')) {
      return "ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้";
    } else if (errorString.contains('timeoutexception')) {
      return "การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง";
    } else if (errorString.contains('formatexception')) {
      return "ข้อมูลจากเซิร์ฟเวอร์ไม่ถูกต้อง";
    } else {
      return "เกิดข้อผิดพลาดในการเชื่อมต่อ กรุณาลองใหม่อีกครั้ง";
    }
  }

  Future<void> _showSuccessDialog(BuyLotteryResPost data) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text("ซื้อสำเร็จ"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("คำสั่งซื้อ: #${data.orderId}"),
            const SizedBox(height: 4),
            Text("เลขสลาก: ${data.number}"),
            const SizedBox(height: 4),
            Text("ราคา: ${data.price} บาท"),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "ยอดเงินคงเหลือ: ${data.wallet} บาท",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ตกลง"),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _modePill(String label, int index) {
    final active = _mode == index;
    return InkWell(
      onTap: () {
        setState(() {
          _mode = index;
          _numberCtrl.clear(); // รีเซ็ต input ตามโหมดใหม่
        });
      },
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
    final balance = _walletOverride ?? _user?.balance.toDouble() ?? 0.0;

    // จำกัดความยาว input ตามโหมด
    final int maxLen = _mode == 2 ? 2 : 3;

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
                        "ค้นหาเลขเด็ด",
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

                const SizedBox(height: 10),

                // โหมดค้นหา
                Wrap(
                  spacing: 10,
                  children: List.generate(
                    _modes.length,
                    (i) => _modePill(_modes[i], i),
                  ),
                ),

                const SizedBox(height: 12),

                // ช่องกรอกเลข
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF69D1DA),
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    controller: _numberCtrl,
                    inputFormatters: [LengthLimitingTextInputFormatter(maxLen)],
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "พิมพ์เลข${_mode == 2 ? " 2 หลัก" : " 3 หลัก"}",
                      hintStyle: const TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ปุ่มค้นหา / สุ่ม
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _loading ? null : _search,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white70,
                            width: 1.5,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "ค้นหาเลข",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _loading ? null : _random,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white70,
                            width: 1.5,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "สุ่มเลข",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ผลการค้นหา
                if (_results.isNotEmpty) ...[
                  Text(
                    "ผลการค้นหา: ${_results.length} รายการ",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: _results.map((lottery) {
                      final rawNumber = lottery.number.toString() ?? "";
                      final shortNumber = shortByMode(rawNumber);
                      final modeName = _modes[_mode];
                      final lotteryId = lottery.lid;
                      final displayPrice = lottery.price.toString() ?? "100";

                      return _ResultCard(
                        rawNumber: rawNumber,
                        shortNumber: shortNumber,
                        modeName: modeName,
                        priceText: "$displayPrice บาท",
                        isBusy: _buyingId == lotteryId,
                        onBuy: lotteryId != null
                            ? () => _buyLottery(lotteryId)
                            : null,
                      );
                    }).toList(),
                  ),
                ] else
                  const Text(
                    "ยังไม่มีผลการค้นหา",
                    style: TextStyle(color: Colors.white54),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 1,
        routeNames: const ['/home', '/myticket', '/wallet', '/member'],
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
        mainAxisSize: MainAxisSize.min,
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

class _ResultCard extends StatelessWidget {
  final String rawNumber;
  final String shortNumber;
  final String modeName;
  final String priceText;
  final bool isBusy;
  final VoidCallback? onBuy;

  const _ResultCard({
    required this.rawNumber,
    required this.shortNumber,
    required this.modeName,
    required this.onBuy,
    this.isBusy = false,
    this.priceText = "100 บาท",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30, width: 1.2),
      ),
      child: Row(
        children: [
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
                      rawNumber.isEmpty ? "------" : rawNumber,
                      style: const TextStyle(
                        letterSpacing: 4,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
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
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ปุ่มซื้อ
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: isBusy ? null : onBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C4BA),
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  elevation: 0,
                ),
                child: isBusy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "ซื้อเลย",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              Text(priceText, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}
