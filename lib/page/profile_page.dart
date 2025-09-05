import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/page/buttom_nav.dart';

class ProfilePage extends StatefulWidget {
  final User? user;
  const ProfilePage({super.key, this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3; // อยู่แท็บสมาชิก

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    final user = args as User?;

    debugPrint("User object: $user");
    debugPrint("User fullName: ${user?.fullName}");
    debugPrint("User email: ${user?.email}");

    return Scaffold(
      // ===== AppBar =====
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
            child: const Text(
              "฿ 9999.99",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      // ===== Body (Gradient + Card กลางจอ) =====
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
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // หัวข้อในกล่อง
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 14),
                  child: const Text(
                    "ข้อมูลสมาชิก",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),

                // ปุ่ม: ข้อมูลส่วนตัว
                _MenuButton(
                  icon: Icons.person_outline,
                  label: "ข้อมูลส่วนตัว",
                  onTap: () {
                    Navigator.pushNamed(context, '/personal', arguments: user);
                  },
                ),
                const SizedBox(height: 10),

                // ปุ่ม: แก้ไขข้อมูลส่วนตัว
                _MenuButton(
                  icon: Icons.edit_outlined,
                  label: "แก้ไขข้อมูลส่วนตัว",
                  onTap: () {
                    // TODO: นำทางไปหน้าแก้ไขข้อมูล
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                  },
                ),
                const SizedBox(height: 18),

                // ปุ่มออกจากระบบ (สีแดง)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // TODO: ทำกระบวนการ logout
                      // Navigator.pushAndRemoveUntil(
                      //   context,
                      //   MaterialPageRoute(builder: (_) => const LoginPage()),
                      //   (_) => false,
                      // );
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
                ),
              ],
            ),
          ),
        ),
      ),

      // ===== Bottom Navigation =====
      bottomNavigationBar: BottomNav(
        currentIndex: 3,
        routeNames: ['/home', '/my-tickets', '/wallet', '/member'],
        argumentsPerIndex: [user, null, user, user],
      ),
    );
  }
}

/// ปุ่มเมนูในกล่องโปร่ง
class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
