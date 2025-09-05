import 'package:flutter/material.dart';

class Login_Page extends StatefulWidget {
  const Login_Page({super.key});

  @override
  State<Login_Page> createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> {
  Color maroon = const Color(0xFF017E89);
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
                    colors: [Color(0xFF017E89)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: 50,
                child: Image.asset('assets/lotto-1-removebg-preview 1.png'),
              ),
              Positioned(
                top: 60,
                child: Center(child: Image.asset('assets/lotto888.png')),
              ),
            ],
          ),
          SizedBox(
            child: Text(
              "จ่ายหนัก จ่ายจริง ไม่จำกัด",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 40),
          Container(
            width: 350,
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 185, 182, 173),
                width: 2,
              ), // เส้นขอบ
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0),
                ),
              ],
            ),

            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 16),
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                      ),
                      SizedBox(height: 10),

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
                              fillColor: Colors.transparent,
                              // พื้นหลังช่อง
                              // เส้นขอบขณะ "ปกติ"
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 172, 169, 158),
                                  width: 2,
                                ),
                              ),
                              // เส้นขอบขณะ "โฟกัส"
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 132, 129, 120),
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
                              fillColor: Colors.transparent, // พื้นหลังช่อง
                              // เส้นขอบขณะ "ปกติ"
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 175, 172, 161),
                                  width: 2,
                                ),
                              ),
                              // เส้นขอบขณะ "โฟกัส"
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 130, 126, 113),
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
                      SizedBox(height: 40),
                      SizedBox(
                        width: 300,
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF00838F), // สีเริ่ม (เขียวฟ้าเข้ม)
                                Color(0xFF4DD0E1), // สีปลาย (เขียวฟ้าอ่อน)
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.transparent, // ทำให้โปร่งใส
                              shadowColor: Colors
                                  .transparent, // ไม่ให้เงาซ้อนกับ gradient
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'เข้าสู่ระบบ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // ตัวหนังสือสีขาว
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'สมัครสมาชิก ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 80),
                          GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => Register_Page()),
                              // );
                            },
                            child: Text(
                              'ลืมรหัสผ่าน?',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
