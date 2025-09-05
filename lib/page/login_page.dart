import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:mobile_lotto/model/request/login_req.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';

import 'package:mobile_lotto/page/menu_page.dart';

class Login_Page extends StatefulWidget {
  const Login_Page({super.key});

  @override
  State<Login_Page> createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> {
  Color maroon = const Color(0xFF017E89);
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _doLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final req = LoginRequest(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      final res = await http.post(
        Uri.parse("https://lotto-api-5jq7.onrender.com/api/Auth/login"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: loginRequestToJson(req),
      );

      log("LOGIN status: ${res.statusCode}");
      log("LOGIN body  : ${res.body}");

      if (res.statusCode == 200) {
        final data = loginResponeFromJson(res.body);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ยินดีต้อนรับ ${data.user.fullName}")),
        );

        // ไปหน้าเมนูและล้างสแต็ก (กัน back กลับ)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Menu_page(user: data.user)),
          (route) => false,
        );
      } else {
        String message = "เข้าสู่ระบบไม่สำเร็จ";
        try {
          final j = jsonDecode(res.body);
          if (j is Map && j["message"] is String) message = j["message"];
        } catch (_) {}
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      log("LOGIN error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เกิดข้อผิดพลาดในการเชื่อมต่อ")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

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
          const SizedBox(
            child: Text(
              "จ่ายหนัก จ่ายจริง ไม่จำกัด",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            width: 350,
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 185, 182, 173),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0))],
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
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
                        const SizedBox(height: 10),

                        // Email
                        SizedBox(
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              controller: emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(color: Colors.white),
                              validator: (v) {
                                final s = v?.trim() ?? '';
                                if (s.isEmpty) return "กรุณากรอกอีเมล";
                                if (!RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(s)) {
                                  return "รูปแบบอีเมลไม่ถูกต้อง";
                                }
                                return null;
                              },
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
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 172, 169, 158),
                                    width: 2,
                                  ),
                                ),
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

                        // Password
                        SizedBox(
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              controller: passwordCtrl,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              style: const TextStyle(color: Colors.white),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? "กรุณากรอกรหัสผ่าน"
                                  : null,
                              onFieldSubmitted: (_) =>
                                  _loading ? null : _doLogin(),
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
                                fillColor: Colors.transparent,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 175, 172, 161),
                                    width: 2,
                                  ),
                                ),
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
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Login Button
                        SizedBox(
                          width: 300,
                          height: 50,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00838F), Color(0xFF4DD0E1)],
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
                              onPressed: _loading ? null : _doLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'เข้าสู่ระบบ',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

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
                            const SizedBox(width: 80),
                            GestureDetector(
                              onTap: () {
                                // Navigator.push(context, MaterialPageRoute(builder: (_) => Register_Page()));
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
