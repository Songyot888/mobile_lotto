import 'package:flutter/material.dart';
import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/model/request/withdraw_req.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/model/response/withdraw_res_post.dart';
import 'package:mobile_lotto/page/buttom_nav.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class WithdrawPage extends StatefulWidget {
  final User? user;
  const WithdrawPage({super.key, this.user});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  User? _user;

  final TextEditingController _accCtrl = TextEditingController();
  final TextEditingController _bankCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();

  bool _loading = false;
  double get balance => _user?.balance ?? widget.user?.balance ?? 0.0;

  @override
  void initState() {
    super.initState();
    // 1) ถ้ามี user ที่ส่งมากับหน้า ให้ใช้ก่อน
    if (widget.user != null) {
      _user = widget.user;
      _applyUserToControllers(widget.user!);
    }
    // 2) จากนั้นพยายามโหลด user ล่าสุดจาก Session
    _loadFromSession();
  }

  @override
  void dispose() {
    _accCtrl.dispose();
    _bankCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 3) ถ้ามี args จาก Route ให้อัปเดต
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is User) {
      _user = args;
      _applyUserToControllers(args);
      setState(() {}); // ให้ UI รีเฟรชยอด/ป้ายต่างๆ
    }
  }

  Future<void> _loadFromSession() async {
    try {
      final u = await Session.getUser();
      if (!mounted) return;
      if (u != null) {
        setState(() {
          _user = u;
          _applyUserToControllers(u);
        });
      }
    } catch (e) {
      log("loadFromSession error: $e");
    }
  }

  // เอาค่าจาก User มาใส่ในฟิลด์: โชว์จริง ไม่ใช้ placeholder
  void _applyUserToControllers(User u) {
    _accCtrl.text = u.bankNumber?.trim().isNotEmpty == true
        ? u.bankNumber!
        //ถ้าไม่มีเลขบัญชี ให้แสดงค่าว่าง
        : '';
    _bankCtrl.text = u.bankName?.trim().isNotEmpty == true ? u.bankName! : '';
  }

  Future<void> _doWithdraw() async {
    if (_loading) return;

    // ต้องมีผู้ใช้ก่อน
    if (_user == null) {
      _showResultDialog('ไม่พบข้อมูลผู้ใช้', success: false);
      return;
    }

    final amountText = _amountCtrl.text.trim();
    final amount = double.tryParse(amountText.replaceAll(',', ''));

    if (amount == null || amount <= 0) {
      _showResultDialog('กรุณากรอกจำนวนเงินให้ถูกต้อง', success: false);
      return;
    }
    if (amount > _user!.balance) {
      _showResultDialog('ยอดเงินไม่พอสำหรับการถอน', success: false);
      return;
    }

    setState(() => _loading = true);

    try {
      final req = WithdrawReq(memberId: _user!.uid, money: amount.toInt());
      log('withdraw memberId=${_user!.uid}, amount=${amount.toInt()}');

      final response = await http.post(
        Uri.parse(
          "https://lotto-api-production.up.railway.app/api/User/withdraw",
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(req.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final withdrawRes = withdrawResPostFromJson(jsonEncode(data));

        // อัปเดตยอดใหม่บนโมเดลและบันทึก Session
        setState(() {
          _user!.balance = withdrawRes.wallet.toDouble();
        });
        await Session.saveUser(_user!);

        _showResultDialog(withdrawRes.message, success: true);
      } else {
        throw Exception('Withdraw failed: ${response.body}');
      }
    } catch (e) {
      _showResultDialog(e.toString(), success: false);
    } finally {
      if (mounted) setState(() => _loading = false);
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
      Navigator.of(context).pop(); // ปิด dialog
      if (success) Navigator.pop(context); // สำเร็จ -> กลับหน้าก่อน
    });
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
                        "ถอนเงิน",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _BalancePill(amount: _user?.balance ?? 0),
                  ],
                ),
                const SizedBox(height: 10),

                // การ์ด
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
                      // เลขบัญชี (จาก User จริง)
                      _CapsuleField(
                        controller: _accCtrl,
                        hint: 'เลขบัญชี',
                        enabled: false, // แสดงผลอย่างเดียว
                        prefixIcon: Icons.credit_card,
                      ),
                      const SizedBox(height: 10),

                      // ชื่อธนาคาร (จาก User จริง)
                      _CapsuleField(
                        controller: _bankCtrl,
                        hint: 'ธนาคาร',
                        enabled: false, // แสดงผลอย่างเดียว
                        prefixIcon: Icons.account_balance,
                      ),
                      const SizedBox(height: 10),

                      // จำนวนที่ต้องการถอน (พิมพ์ได้)
                      _CapsuleField(
                        controller: _amountCtrl,
                        hint: 'กรอกจำนวนที่ต้องการถอน',
                        keyboard: TextInputType.number,
                        prefixIcon: Icons.attach_money,
                      ),
                      const SizedBox(height: 14),

                      // ปุ่มคู่
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _loading ? null : _doWithdraw,
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
                                      "ถอนเงิน",
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

class _CapsuleField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final TextInputType? keyboard;
  final IconData? prefixIcon;

  const _CapsuleField({
    required this.controller,
    required this.hint,
    this.enabled = true,
    this.keyboard,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF69D1DA), width: 2),
      ),
      child: Row(
        children: [
          if (prefixIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(prefixIcon, color: Colors.white70, size: 20),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboard,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
