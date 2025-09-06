import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/page/buttom_nav.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  User? _user;

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
      setState(() {
        _user = u;
      });
    } else {
      setState(() {});
    }
  }

  // ---------- UI helper: ช่องครอบ (pill) พร้อมไอคอน/ท้าย ----------
  Widget _pill(String text, {IconData? icon, Widget? trailing}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.45), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              text.isEmpty ? '-' : text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(
      context,
    )!.settings.arguments; // ไม่ได้ใช้ก็ปล่อยไว้ได้
    debugPrint("User object: $_user");
    debugPrint("User fullName: ${_user?.fullName}");
    debugPrint("User email: ${_user?.email}");
    debugPrint("User phone: ${_user?.phone}");

    // ป้องกัน null ตอนฟอร์แมทยอดเงิน
    final balanceText =
        "฿ ${((_user?.balance ?? 0) as num).toStringAsFixed(2)}";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF006064),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "ข้อมูลสมาชิก",
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
              balanceText,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.6),
                    width: 1,
                  ),
                ),
                child: _user == null
                    ? const Text(
                        "ไม่พบข้อมูลผู้ใช้",
                        style: TextStyle(color: Colors.white),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _pill(
                            _user?.fullName ?? '-',
                            icon: Icons.person_outline,
                          ),
                          _pill(
                            _user?.email ?? '-',
                            icon: Icons.alternate_email,
                          ),
                          _pill(
                            _user?.phone ?? '-',
                            icon: Icons.phone_outlined,
                          ),
                          _pill(
                            _user?.bankName ?? '-',
                            icon: Icons.account_balance_outlined,
                          ),
                          _pill(
                            _user?.bankNumber ?? '-',
                            icon: Icons.credit_card_outlined,
                          ),
                          _pill(
                            balanceText,
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                        ],
                      ),
              ),
            ),
          ),
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
