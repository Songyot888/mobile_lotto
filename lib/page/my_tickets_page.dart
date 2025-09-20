import 'package:flutter/material.dart';
import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/page/buttom_nav.dart'; // ใช้ BottomNav ของโปรเจกต์คุณ

class MyTicketsPage extends StatefulWidget {
  final User? user;
  const MyTicketsPage({super.key, this.user});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  User? _user;
  double get balance => widget.user?.balance ?? 0.0;

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
    // ตัวอย่างรายการที่ซื้อ (Mock)
    final tickets = <_Ticket>[
      _Ticket(number: "5187456", price: 100, status: "สำเร็จ"),
      _Ticket(number: "5187456", price: 100, status: "สำเร็จ"),
    ];

    return Scaffold(
      // ✅ พื้นหลังเต็มจอ
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
                // แถวบน: Back + Title + Balance
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
                        "หวยของฉัน",
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

                const SizedBox(height: 12),

                // รายการที่ซื้อ
                Column(
                  children: tickets.map((t) => _TicketCard(ticket: t)).toList(),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),

      // ✅ BottomNav: ไฮไลต์แท็บ "หวยของฉัน" (index = 1)
      bottomNavigationBar: BottomNav(
        currentIndex: 1,
        routeNames: const ['/home', '/buy', '/wallet', '/member'],
        // ถ้า BottomNav รองรับ argumentsPerIndex ให้ส่ง user ไปด้วย:
        // argumentsPerIndex: [user, user, user, user],
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

class _Ticket {
  final String number;
  final int price;
  final String status;
  const _Ticket({
    required this.number,
    required this.price,
    required this.status,
  });
}

class _TicketCard extends StatelessWidget {
  final _Ticket ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // กล่องเลขเหลือง
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE082), // เหลืองอ่อน
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  // ใส่เว้นวรรคเล็กน้อยให้ฟีลเหมือนดีไซน์
                  ticket.number,
                  style: const TextStyle(
                    letterSpacing: 4,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ราคา + สถานะ
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "ราคา: ${ticket.price} บาท",
                style: const TextStyle(color: Colors.white70, fontSize: 12.5),
              ),
              const SizedBox(height: 10),
              Text(
                ticket.status,
                style: const TextStyle(
                  color: Color(0xFF00C4BA), // เขียวอมฟ้า "สำเร็จ"
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
