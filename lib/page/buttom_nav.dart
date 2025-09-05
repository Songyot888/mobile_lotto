// lib/page/bottom_nav.dart
import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex; // แท็บที่แอคทีฟของหน้านี้
  final List<String> routeNames; // ชื่อ route ของแต่ละแท็บ (ต้องมี 4 ตัว)

  /// (ทางเลือก) arguments สำหรับแต่ละแท็บ ถ้ามีให้ส่งความยาว = 4
  /// เช่น [null, null, null, user] เพื่อส่งให้แท็บ "สมาชิก"
  final List<Object?>? argumentsPerIndex;

  /// (ทางเลือก) custom handler ถ้าอยากควบคุมการนำทางเองทั้งหมด
  final void Function(BuildContext context, int index)? onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.routeNames,
    this.argumentsPerIndex,
    this.onTap,
  }) : assert(routeNames.length == 4, 'routeNames ต้องมี 4 รายการ');

  void _defaultOnTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    final args = (argumentsPerIndex != null && argumentsPerIndex!.length == 4)
        ? argumentsPerIndex![index]
        : null;

    Navigator.pushReplacementNamed(
      context,
      routeNames[index],
      arguments: args, // ✅ ส่ง arguments ถ้ามี
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF085056),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: currentIndex,
      onTap: (i) =>
          (onTap != null) ? onTap!(context, i) : _defaultOnTap(context, i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "หน้าแรก"),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: "หวยของฉัน",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "กระเป๋าเงิน"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "สมาชิก"),
      ],
    );
  }
}
