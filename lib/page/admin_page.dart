import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/page/login_page.dart';
import 'package:mobile_lotto/page/wallet_page.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/model/request/clear_req.dart';
import 'package:mobile_lotto/model/response/clear_res_post.dart';

const _clearEndpoint =
    "https://lotto-api-production.up.railway.app/api/Admin/clear";

/// =====================
/// ไอคอนสไตล์วงกลมโปร่งใส + ขอบ
/// =====================
class FancyIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const FancyIcon({super.key, required this.icon, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 20,
      height: size + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.6),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}

class AdminPage extends StatefulWidget {
  final User? user;
  const AdminPage({super.key, this.user});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  User? _user;
  bool _loading = true;
  bool _clearing = false; // ระหว่างยิง clear

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (widget.user != null) {
      _user = widget.user;
    } else if (args is User) {
      _user = args;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _bootstrap() async {
    final u = await Session.getUser();
    if (!mounted) return;
    setState(() => _user = u ?? _user);
  }

  // ======== UI ========
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final displayName = _user?.fullName ?? "สมาชิก";

    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลังไล่สีแบบเต็มหน้า
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF006064),
                  Color(0xFF00838F),
                  Color(0xFF006064),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // คอนเทนต์เต็มหน้า + เลื่อนทั้งหน้าได้
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // โลโก้/หัวหน้า
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: -5,
                        top: 5,
                        child: Image.asset(
                          'assets/lotto-1-removebg-preview 1.png',
                          height: 100,
                        ),
                      ),
                      Image.asset('assets/lotto888.png', height: 180),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "สวัสดี, $displayName",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "ADMIN PAGE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // เมนูแบบ Grid เต็มความกว้าง
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.05,
                  children: [
                    buildMenuCard(
                      Icons.add,
                      "เพิ่มล็อตเตอรี่",
                      onTap: () => Navigator.pushNamed(context, '/addlottery'),
                    ),
                    buildMenuCard(
                      Icons.refresh,
                      "สุ่มผลรางวัล",
                      onTap: () => Navigator.pushNamed(context, '/random-draw'),
                    ),
                    buildMenuCard(
                      Icons.restart_alt,
                      "รีเซ็ตระบบ",
                      onTap: _confirmAndClear, // กล่องยืนยัน + ยิง API
                    ),
                    buildMenuCard(
                      Icons.new_releases,
                      "ล็อตเตอรี่ทั้งหมด",
                      onTap: () => Navigator.pushNamed(context, '/all'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ปุ่มออกจากระบบเต็มความกว้าง
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    await Session.logout();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const Login_Page()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "ออกจากระบบ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // ชั้น Overlay ตอนกำลังรีเซ็ต
          if (_clearing)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      "กำลังรีเซ็ตระบบ...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildMenuCard(
    IconData icon,
    String text, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        if (text == "เครดิตเงิน(Wallet)") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Wallet_Page()),
          );
        } else {
          onTap();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromARGB(255, 0, 196, 186),
            width: 1.6,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 4),
            FancyIcon(icon: icon, size: 42),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======== Logic: Confirm & Call API ========
  Future<void> _confirmAndClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: !_clearing,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('ยืนยันการรีเซ็ตระบบ'),
          content: const Text(
            'การรีเซ็ตจะล้างข้อมูลที่เกี่ยวข้องตามที่ระบบกำหนด\nคุณแน่ใจหรือไม่ว่าจะดำเนินการต่อ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('ยืนยัน'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await _callClearApi();
  }

  Future<void> _callClearApi() async {
    if (_user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่พบข้อมูลผู้ใช้')));
      return;
    }

    setState(() => _clearing = true);

    try {
      final headers = <String, String>{'Content-Type': 'application/json'};

      // ✅ ใช้ id ให้ตรงกับโมเดล User (ส่งเป็น "uid" ตาม ClearReq)
      final body = ClearReq(uid: _user!.uid).toJson();

      final resp = await http.post(
        Uri.parse(_clearEndpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        String message = 'รีเซ็ตระบบสำเร็จ';
        try {
          final data = ClearResPost.fromJson(jsonDecode(resp.body));
          if (data.message.isNotEmpty) message = data.message;
        } catch (_) {}
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));

        // (ถ้าต้องการ) รีเฟรช/นำผู้ใช้กลับหน้าหลัก
        // Navigator.popUntil(context, (route) => route.isFirst);
        // Navigator.pushReplacementNamed(context, '/admin');
      } else {
        String errMsg = 'รีเซ็ตไม่สำเร็จ (${resp.statusCode})';
        try {
          final decoded = jsonDecode(resp.body);
          if (decoded is Map && decoded['message'] is String) {
            errMsg = decoded['message'];
          }
        } catch (_) {}
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errMsg)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }
}
