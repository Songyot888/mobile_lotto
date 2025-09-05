// lib/page/bottom_nav.dart
import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;          // แท็บที่แอคทีฟของหน้านี้
  final List<String> routeNames;   // ชื่อ route ของแต่ละแท็บ (ต้องมี 4 ตัว)

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.routeNames,
  }) : assert(routeNames.length == 4, 'routeNames ต้องมี 4 รายการ');

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    Navigator.pushReplacementNamed(context, routeNames[index]);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF085056),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: currentIndex,
      onTap: (i) => _onTap(context, i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "หน้าแรก"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: "หวยของฉัน"),
        BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "กระเป๋าเงิน"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "สมาชิก"),
      ],
    );
  }
}
