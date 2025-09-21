import 'package:flutter/material.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/page/buttom_nav.dart';

class SearchNumberPage extends StatefulWidget {
  final User? user;
  const SearchNumberPage({super.key, this.user});

  @override
  State<SearchNumberPage> createState() => _SearchNumberPageState();
}

class _SearchNumberPageState extends State<SearchNumberPage> {
  final TextEditingController _numberCtrl = TextEditingController();

  @override
  void dispose() {
    _numberCtrl.dispose();
    super.dispose();
  }

  void _clear() => setState(() => _numberCtrl.clear());

  void _search() {
    final s = _numberCtrl.text.trim();
    if (s.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกเลขที่ต้องการค้นหา')),
      );
      return;
    }
    // TODO: ต่อ API ค้นหาเลขจริง
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ค้นหาเลข: $s (ตัวอย่าง)')),
    );
  }

  void _random() {
    // สุ่มเลข 6 หลักตัวอย่าง
    final now = DateTime.now().microsecondsSinceEpoch;
    final rnd = (now % 1000000).toString().padLeft(6, '0');
    setState(() => _numberCtrl.text = rnd);
  }

  @override
  Widget build(BuildContext context) {
    final balance = widget.user?.balance?.toDouble() ?? 9999.99;

    return Scaffold(
      // ✅ พื้นหลังเต็มจอ
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
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
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        "ซื้อสลากกินแบ่ง",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _BalancePill(amount: balance),
                  ],
                ),

                const SizedBox(height: 10),

                // หัวข้อ “ค้นหาเลขเด็ด” + ปุ่มล้างค่า
                Row(
                  children: [
                    const Text(
                      "ค้นหาเลขเด็ด\nงวดวันที่ 13 มิ.ย 2565",
                      style: TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clear,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                      ),
                      child: const Text("ล้างค่า"),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // กล่องกรอกเลข (สไตล์แคปซูล)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF69D1DA), width: 2),
                  ),
                  child: TextField(
                    controller: _numberCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "พิมพ์เลขที่ต้องการค้นหา",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ปุ่มคู่: ค้นหาเลข / สุ่มเลข
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _search,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white70, width: 1.5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("ค้นหาเลข", style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _random,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white70, width: 1.5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("สุ่มเลข", style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // เส้นขอบโค้งด้านล่าง (เพื่อฟีลเหมือน mock)
                Container(
                  height: 14,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24, width: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // BottomNav (แท็บหวยของฉัน)
      bottomNavigationBar: BottomNav(
        currentIndex: 1,
        routeNames: const ['/home', '/buy', '/wallet', '/member'],
      ),
    );
  }
}

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
          const Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            amount.toStringAsFixed(2),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
