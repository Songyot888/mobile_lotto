import 'package:flutter/material.dart';
import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/page/buttom_nav.dart';

class Wallet_Page extends StatefulWidget {
  const Wallet_Page({super.key});

  @override
  State<Wallet_Page> createState() => _Wallet_PageState();
}

class _Wallet_PageState extends State<Wallet_Page> {
  User? _user;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF006064), Color(0xFF00838F), Color(0xFF006064)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
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
                    Image.asset('assets/lotto888.png', height: 120),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.teal.shade700.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white70, width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      "เครดิตที่ใช้ได้",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // ✅ ใช้ ValueListenableBuilder เพื่อรับค่าจาก Session
                    ValueListenableBuilder<User?>(
                      valueListenable: Session.currentUser,
                      builder: (context, user, child) {
                        final displayBalance =
                            user?.balance ?? _user?.balance ?? 0.0;
                        return Text(
                          " ${displayBalance.toStringAsFixed(2)} ฿",
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // ... rest of the widgets remain the same
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final refreshed = await Navigator.pushNamed(
                        context,
                        '/topup',
                      );
                      if (!mounted) return;
                      // ✅ ไม่จำเป็นต้อง _loadFromSession() แล้ว เพราะใช้ ValueListenableBuilder
                      // if (refreshed == true) {
                      //   _loadFromSession();
                      // }
                    },
                    child: const Text(
                      "เติมเงิน",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/withdraw');
                    },
                    child: const Text(
                      "ถอนเงิน",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildMenuButton(
                Icons.receipt_long,
                "ประวัติการซื้อ",
                onTap: () {
                  Navigator.pushNamed(context, '/purchase-history');
                },
              ),
              const SizedBox(height: 15),
              _buildMenuButton(
                Icons.emoji_events,
                "ประวัติการถูกรางวัล",
                onTap: () {
                  Navigator.pushNamed(context, '/winning-history');
                },
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNav(
        currentIndex: 2,
        routeNames: ['/home', '/my-tickets', '/wallet', '/member'],
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

  Widget _buildMenuButton(
    IconData icon,
    String text, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal.shade900, size: 28),
            const SizedBox(width: 15),
            Text(
              text,
              style: TextStyle(
                color: Colors.teal.shade900,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
