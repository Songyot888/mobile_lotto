import 'package:flutter/material.dart';
import 'package:mobile_lotto/page/wallet_page.dart';

class Menu_page extends StatefulWidget {
   const Menu_page({super.key});

  @override
  State<Menu_page> createState() => _Menu_pageState();
}

class _Menu_pageState extends State<Menu_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height, // ครอบเต็มหน้าจอ
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

              // 🔹 รูปซ้อนกัน
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
              const Text(
                "จ่ายหนัก จ่ายจริง ไม่จำกัด",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

             // 🔹 เมนู 4 ปุ่ม (Grid)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    buildMenuCard(Icons.shopping_cart, "ซื้อหวย"),
                    buildMenuCard(Icons.account_balance_wallet, "เครดิตเงิน(Wallet)"),
                    buildMenuCard(Icons.verified, "ตรวจลอตเตอรี่"),
                    buildMenuCard(Icons.access_time, "ผลรางวัลงวดที่ผ่านมา"),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // 🔹 แถบเมนูล่าง
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF085056),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "หน้าแรก"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: "หวยของฉัน"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "กระเป๋าเงิน"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "สมาชิก"),
        ],
      ),
    );
  }

  // 🔹 ฟังก์ชันสร้างการ์ดเมนู
  Widget buildMenuCard(IconData icon, String text) {
    return InkWell(
     onTap: () {
      if (text == "เครดิตเงิน(Wallet)") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Wallet_Page()),
        );
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
            )
          ],
        ),
      ),
    );
  }
}