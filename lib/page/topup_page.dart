import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/page/buttom_nav.dart';

class TopupReq {
  int memberId;
  int money;
  TopupReq({required this.memberId, required this.money});
  Map<String, dynamic> toJson() => {"memberId": memberId, "money": money};
}

// Topup Response
class TopupResPost {
  final String message;
  final int memberId;
  final int amount;
  final int wallet;
  TopupResPost({
    required this.message,
    required this.memberId,
    required this.amount,
    required this.wallet,
  });
  factory TopupResPost.fromJson(Map<String, dynamic> json) => TopupResPost(
    message: json["message"],
    memberId: json["memberId"],
    amount: json["amount"],
    wallet: json["wallet"],
  );
}
// ================================================================

class TopUpPage extends StatefulWidget {
  final User? user;
  const TopUpPage({super.key, this.user});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  User? _user;
  final TextEditingController _amountCtrl = TextEditingController();
  bool _loading = false;
  VoidCallback? _userListener;

  @override
  void initState() {
    super.initState();
    _loadFromSession();
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
    final u = await Session.getUser();
    if (!mounted) return;
    if (u != null) {
      setState(() {
        _user = u;
      });
    } else {
      setState(() {});
    }
  }

  void _showResultDialog(String msg, {bool success = true}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF00838F),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      if (success) Navigator.pop(context, true);
    });
  }

  Future<void> _doTopup() async {
    if (_loading) return;

    final s = _amountCtrl.text.trim();
    final amount = double.tryParse(s.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      _showResultDialog('กรุณากรอกจำนวนเงินให้ถูกต้อง', success: false);
      return;
    }

    final memberId = (_user?.uid ?? widget.user?.uid);
    if (memberId == null) {
      _showResultDialog('ไม่พบรหัสสมาชิก (memberId)', success: false);
      return;
    }

    setState(() => _loading = true);
    try {
      final req = TopupReq(memberId: memberId, money: amount.round());
      final uri = Uri.parse(
        "https://lotto-api-production.up.railway.app/api/User/topup",
      );

      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(req.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        double? newWallet;
        String successMsg = 'ทำรายการสำเร็จ';
        try {
          final decoded = jsonDecode(resp.body);
          if (decoded is Map<String, dynamic>) {
            // รองรับโครงสร้างที่แตกต่างกัน
            if (decoded['wallet'] is num) {
              newWallet = (decoded['wallet'] as num).toDouble();
            } else if (decoded['balance'] is num) {
              newWallet = (decoded['balance'] as num).toDouble();
            } else if (decoded['newWallet'] is num) {
              newWallet = (decoded['newWallet'] as num).toDouble();
            }
            if (decoded['message'] is String &&
                (decoded['message'] as String).isNotEmpty) {
              successMsg = decoded['message'] as String;
            }
          }
        } catch (_) {
        }

        if (newWallet != null) {
          // อัปเดตยอดใน Session เพื่อ notify ทุกหน้า
          await Session.updateBalance(newWallet);
          if (_user != null) {
            setState(() {
              _user!.balance = newWallet!;
            });
          }
        }

        _showResultDialog(successMsg, success: true);
      } else {
        String apiMsg = 'เกิดข้อผิดพลาด (${resp.statusCode})';
        try {
          final m = jsonDecode(resp.body);
          if (m is Map && m['message'] is String) apiMsg = m['message'];
        } catch (_) {}
        _showResultDialog(apiMsg, success: false);
      }
    } on TimeoutException {
      _showResultDialog('การเชื่อมต่อหมดเวลา กรุณาลองใหม่', success: false);
    } on SocketException {
      _showResultDialog('ไม่มีการเชื่อมต่ออินเทอร์เน็ต', success: false);
    } on FormatException {
      // กรณีตอบกลับไม่ใช่ JSON แต่ status OK จะไม่มาถึงตรงนี้ (เราครอบไว้ข้างบนแล้ว)
      _showResultDialog('ข้อมูลจากเซิร์ฟเวอร์ไม่ถูกต้อง', success: false);
    } catch (e) {
      _showResultDialog(
        'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้ กรุณาลองใหม่',
        success: false,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    if (_userListener != null) {
      Session.currentUser.removeListener(_userListener!);
    }
    super.dispose();
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
                        "ช่องทางการชำระเงิน",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<User?>(
                      valueListenable: Session.currentUser,
                      builder: (context, user, child) {
                        final display = user?.balance ?? 0.0;
                        return _BalancePill(amount: display);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white54, width: 1.4),
                  ),
                  child: Column(
                    children: [
                      // ช่องเลือก wallet
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF69D1DA),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              "true money wallet",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Image.asset(
                              'assets/truemoney.png',
                              height: 22,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Amount
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF69D1DA),
                            width: 2,
                          ),
                        ),
                        child: TextField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "จำนวนเงินที่ต้องการ",
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _loading ? null : _doTopup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
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
                                      "เติมเงิน",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _loading
                                  ? null
                                  : () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD32F2F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "ยกเลิก",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 2,
        routeNames: const ['/home', '/buy', '/wallet', '/member'],
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
