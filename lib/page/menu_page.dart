import 'package:flutter/material.dart';
import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/page/buttom_nav.dart';
import 'package:mobile_lotto/page/wallet_page.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/page/profile_page.dart';

class Menu_page extends StatefulWidget {
  final User? user;
  const Menu_page({super.key, this.user});

  @override
  State<Menu_page> createState() => _Menu_pageState();
}

class _Menu_pageState extends State<Menu_page> {
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (widget.user != null) {
      _user = widget.user;
    } else {
      if (args is User) {
        _user = args;
      }
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _bootstrap() async {
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final displayName = _user?.fullName ?? "สมาชิก";

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
                    Image.asset('assets/lotto888.png', height: 180),
                  ],
                ),
              ),
              const SizedBox(height: 10),
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
                "จ่ายหนัก จ่ายจริง ไม่จำกัด",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    buildMenuCard(
                      Icons.shopping_cart,
                      "ซื้อหวย",
                      onTap: () {
                        Navigator.pushNamed(context, '/buy');
                      },
                    ),
                    buildMenuCard(
                      Icons.account_balance_wallet,
                      "เครดิตเงิน(Wallet)",
                      onTap: () {
                        Navigator.pushNamed(context, '/wallet');
                      },
                    ),
                    buildMenuCard(
                      Icons.verified,
                      "ตรวจลอตเตอรี่",
                      onTap: () {
                        Navigator.pushNamed(context, '/check-lottery');
                      },
                    ),
                    buildMenuCard(
                      Icons.access_time,
                      "ผลรางวัลงวดที่ผ่านมา",
                      onTap: () {
                        Navigator.pushNamed(context, '/previous-results');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNav(
        currentIndex: 0,
        routeNames: ['/home', '/my-tickets', '/wallet', '/member'],
        argumentsPerIndex: [_user, null, _user, _user],
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
          onTap(); // ✅ เรียก callback ที่ส่งเข้ามา
        }
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color.fromARGB(255, 0, 196, 186),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              text,
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
    );
  }
}
