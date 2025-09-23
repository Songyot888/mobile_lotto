import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/model/request/buy_lotterry_req.dart';
import 'package:mobile_lotto/model/response/all_lottery_res_get.dart';
import 'package:mobile_lotto/model/response/buy_lottery_res_post.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/page/buttom_nav.dart';

// ========================
// Endpoints
// ========================
const _unsoldEndpoint =
    "https://lotto-api-production.up.railway.app/api/User/unsold";
const _buyEndpoint = "https://lotto-api-production.up.railway.app/api/User/buy";

class BuyLottoPage extends StatefulWidget {
  final User? user;
  const BuyLottoPage({super.key, this.user});

  @override
  State<BuyLottoPage> createState() => _BuyLottoPageState();
}

class _BuyLottoPageState extends State<BuyLottoPage> {
  User? _user;
  List<AllLotteryResGet> allLotteryresget = [];
  VoidCallback? _userListener;

  // โหมดที่เลือก: 0=3ตัวหน้า, 1=3ตัวหลัง, 2=2ตัว
  int _mode = 0;
  final List<String> _modes = ["3ตัวหน้า", "3ตัวหลัง", "2ตัว"];

  // กันกดซ้ำ & อัปเดตยอดเงินโชว์ทันที
  int? _buyingId;
  double? _walletOverride;

  // หา memberId จากโมเดล User
  int? get _memberId {
    return _user?.uid;
  }

  @override
  void initState() {
    super.initState();
    _loadFromSession();
    _loadAllLotteries();
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
    setState(() {});
  }

  Future<void> _loadFromSession() async {
    try {
      final u = await Session.getUser();
      if (mounted && u != null) {
        setState(() {
          _user = u;
        });
      }
    } catch (e) {
      log('Error loading user from session: $e');
    }
  }

  Future<void> _loadAllLotteries() async {
    try {
      final res = await http.get(
        Uri.parse(_unsoldEndpoint),
        headers: {"Content-Type": "application/json; charset=utf-8"},
      );

      if (res.statusCode == 200) {
        final parsed = allLotteryResGetFromJson(res.body);
        if (mounted) {
          setState(() {
            allLotteryresget = parsed;
          });
        }
      } else {
        if (mounted) {
          _showErrorSnackBar(
            'ไม่สามารถดึงข้อมูลได้ในขณะนี้ กรุณาลองใหม่อีกครั้ง',
          );
        }
      }
    } catch (e) {
      log("Error loading lotteries: $e");
      if (mounted) {
        _showErrorSnackBar('เกิดข้อผิดพลาดในการเชื่อมต่อ');
      }
    }
  }

  // คืนเลขตามโหมดที่เลือก
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

        // ✅ อัพเดตยอดเงินทันทีใน UI
        setState(() {
          _walletOverride = data.wallet.toDouble();
          // ลบรายการที่ซื้อแล้วออกจากลิสต์
          allLotteryresget.removeWhere((x) => x.lid == lotteryId);
        });

        // ✅ อัพเดต Session และ notify ทุก listeners
        await Session.updateBalance(data.wallet.toDouble());

        // แสดงข้อความสำเร็จ
        await _showSuccessDialog(data);
      } else {
        // จัดการข้อผิดพลาดตาม HTTP status
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

  // ปุ่มโหมด
  Widget _buildModePill(String label, int index) {
    final isActive = _mode == index;
    return InkWell(
      onTap: () => setState(() => _mode = index),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF006064) : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = _walletOverride ?? _user?.balance.toDouble() ?? 0.0;

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

                // ปุ่มโหมด
                Wrap(
                  spacing: 10,
                  children: List.generate(
                    _modes.length,
                    (i) => _buildModePill(_modes[i], i),
                  ),
                ),

                const SizedBox(height: 12),

                // ปุ่มค้นหาเลข
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/search', arguments: _user);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white70, width: 1.5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text(
                      "ค้นหาเลข",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "เลขแนะนำประจำวัน\nสลากกินแบ่งรัฐบาล",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),

                // จำนวนทั้งหมด
                Text(
                  "พบทั้งหมด ${allLotteryresget.length} รายการ",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),

                // การ์ดเลขแนะนำ
                if (allLotteryresget.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        "ไม่มีสลากให้ซื้อในขณะนี้",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  )
                else
                  Column(
                    children: allLotteryresget.map((lottery) {
                      final rawNumber = lottery.number.toString();
                      final shortNumber = shortByMode(rawNumber);
                      final modeName = _modes[_mode];
                      final lotteryId = lottery.lid;
                      final displayPrice = lottery.price.toString();

                      return _SuggestionCard(
                        rawNumber: rawNumber,
                        shortNumber: shortNumber,
                        modeName: modeName,
                        isBusy: _buyingId == lotteryId,
                        priceText: "$displayPrice บาท",
                        onBuy: () => _buyLottery(lotteryId),
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
        routeNames: const ['/home', '/my-tickets', '/wallet', '/member'],
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

class _SuggestionCard extends StatelessWidget {
  final String rawNumber;
  final String shortNumber;
  final String modeName;
  final String priceText;
  final bool isBusy;
  final VoidCallback? onBuy;

  const _SuggestionCard({
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30, width: 1.2),
      ),
      child: Row(
        children: [
          // เลขเต็ม + ป้ายโหมดเล็ก
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
                        letterSpacing: 0.5,
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
