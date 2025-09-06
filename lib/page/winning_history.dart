import 'package:flutter/material.dart';
import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/page/buttom_nav.dart';

class WinningHistory extends StatefulWidget {
  const WinningHistory({super.key});

  @override
  State<WinningHistory> createState() => _WinningHistoryState();
}

class _WinningHistoryState extends State<WinningHistory> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF006064), // ✅ สีเดียวกับพื้นหลังด้านบน
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "ประวัติการถูกรางวัล",
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
              "฿ ${(_user?.balance ?? 0).toStringAsFixed(2)}",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

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
        child: const Center(
          child: Text(
            "เนื้อหาประวัติการถูกรางวัล",
            style: TextStyle(color: Colors.white, fontSize: 18),
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
