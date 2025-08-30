import 'package:flutter/material.dart';

class Login_Page extends StatefulWidget {
  const Login_Page({super.key});

  @override
  State<Login_Page> createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> {
  Color maroon = const Color(0xFF4A0E0E);
  Color maroonDark = const Color(0xFF2E0707);
  Color gold = const Color(0xFFD3A400);
  TextEditingController emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: maroon,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 250,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD32F2F), Color.fromARGB(255, 0, 0, 0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                child: Image.asset('assets/lotto-1-removebg-preview 1.png'),
              ),
              Center(child: Image.asset('assets/lotto888.png')),

              Positioned(
                left: 110,
                top: 160,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroonDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: gold, width: 1.5),
                      ),
                    ),
                    child: const Text(
                      'สมัครสมาชิก',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
          Container(
            width: 350,
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.amber, width: 2), // เส้นขอบ
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0),
                ),
              ],
              image: DecorationImage(
                image: AssetImage('assets/sa-removebg-preview 1.png'),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Text(
                            'ยินดีต้อนรับสู่ LOTTO888',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 220,
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Text(
                                  'แอปขายหวยออนไลน์ อันดับ 1 จ่ายหนัก จ่ายจริง ไม่จำกัด ',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: TextField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction:
                                TextInputAction.next, // กด Enter ไปช่องถัดไป
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'อีเมล',
                              labelStyle: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              hintText: 'name@example.com',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              filled: true,
                              fillColor: const Color(
                                0xFF4A0E0E,
                              ), // พื้นหลังช่อง
                              // เส้นขอบขณะ "ปกติ"
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD3A400),
                                  width: 2,
                                ),
                              ),
                              // เส้นขอบขณะ "โฟกัส"
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD3A400),
                                  width: 2.4,
                                ),
                              ),

                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  'assets/User.png',
                                  color: Colors.white,
                                  width: 22,
                                  height: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: TextField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction:
                                TextInputAction.next, // กด Enter ไปช่องถัดไป
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'รหัสผ่าน',
                              labelStyle: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              hintText: 'password',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              filled: true,
                              fillColor: const Color(
                                0xFF4A0E0E,
                              ), // พื้นหลังช่อง
                              // เส้นขอบขณะ "ปกติ"
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD3A400),
                                  width: 2,
                                ),
                              ),
                              // เส้นขอบขณะ "โฟกัส"
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD3A400),
                                  width: 2.4,
                                ),
                              ),

                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  'assets/User.png',
                                  color: Colors.white,
                                  width: 22,
                                  height: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'ลืมรหัสผ่าน ?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.amberAccent,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: gold, width: 1.5),
                            ),
                          ),
                          child: const Text(
                            'เข้าสู่ระบบ',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
