import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_lotto/model/request/register_req.dart';
import 'package:mobile_lotto/model/response/register_res_post.dart';

class Register_Page extends StatefulWidget {
  const Register_Page({super.key});

  @override
  State<Register_Page> createState() => _Register_PageState();
}

class _Register_PageState extends State<Register_Page> {
  // ✅ Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController bankController = TextEditingController();
  final TextEditingController accountController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  bool _submitting = false; // กันกดซ้ำ + แสดงสถานะกำลังสมัคร

  // ✅ Popup การ์ดแจ้งผล (สไตล์ตามรูป)
  void _showResultDialog(String message, {bool success = true}) {
    showDialog(
      context: context,
      barrierDismissible: false, // กันกดนอกกล่องปิด
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: const Color(0xFF00838F), // โทนฟ้าเขียว
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );

    // ปิด dialog อัตโนมัติใน 1.6 วิ แล้วถ้าสำเร็จค่อยเด้งกลับ login
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).pop(); // ปิด dialog
      if (success) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    });
  }

  // ✅ สมัครสมาชิกแล้วแสดงผล + กลับหน้า Login
  Future<void> registerUser() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final req = RegisterRequest(
        fullName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        bankName: bankController.text.trim(),
        bankNumber: accountController.text.trim(),
        password: passwordController.text,
        balance: int.tryParse(balanceController.text.trim()) ?? 0,
      );

      final res = await http.post(
        Uri.parse("https://lotto-api-production.up.railway.app/api/Auth/register"),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: registerRequestToJson(req),
      );

      log('statusCode: ${res.statusCode}');
      log('body: ${res.body}');

      if (!mounted) return;

      // สำเร็จ (200/201)
      if (res.statusCode == 200 || res.statusCode == 201) {
        // ถ้าต้อง parse response
        try {
          final RegisterRespone parsed = registerResponeFromJson(res.body);
          log('registered: ${parsed.fullName}');
        } catch (_) {/* ถ้า parse ไม่ได้ก็ข้ามได้ */}
        _showResultDialog("ระบบได้ทำรายการสมัครให้เรียบร้อย", success: true);
        return;
      }

      // ข้อมูลซ้ำ (บาง API ใช้ 400 หรือ 409)
      if (res.statusCode == 400 || res.statusCode == 409) {
        _showResultDialog("ข้อมูลซ้ำ กรุณาตรวจสอบอีเมล/เบอร์โทร/บัญชีธนาคาร", success: false);
        return;
      }

      // อื่น ๆ
      _showResultDialog("สมัครไม่สำเร็จ (${res.statusCode}) กรุณาลองใหม่", success: false);
    } catch (e) {
      log('Error $e');
      if (!mounted) return;
      _showResultDialog("เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์", success: false);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    bankController.dispose();
    accountController.dispose();
    balanceController.dispose();
    super.dispose();
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

              // 🔹 Logo
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: -5,
                      top: 5,
                      child: Image.asset('assets/lotto-1-removebg-preview 1.png', height: 100),
                    ),
                    Image.asset('assets/lotto888.png', height: 180),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                "จ่ายหนัก จ่ายจริง ไม่จำกัด",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // 🔹 Card Form
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color.fromARGB(255, 0, 196, 186), width: 3),
                ),
                child: Column(
                  children: [
                    const Text(
                      "สมัครสมาชิก",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),

                    // 🔹 Input Fields
                    buildTextField("ชื่อนามสกุล", Icons.person, nameController),
                    buildTextField("เบอร์โทรศัพท์", Icons.phone, phoneController),
                    buildTextField("อีเมล์", Icons.email, emailController),
                    buildTextField("รหัสผ่าน", Icons.lock, passwordController, isPassword: true),
                    buildTextField("ชื่อธนาคาร", Icons.account_balance, bankController),
                    buildTextField("เลขบัญชี", Icons.account_balance_wallet, accountController),
                    buildTextField("จำนวนเงิน", Icons.account_balance_wallet, balanceController),

                    const SizedBox(height: 20),

                    // 🔹 สมัครสมาชิก
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 196, 186),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color.fromARGB(255, 0, 196, 186), width: 2),
                          ),
                        ),
                        child: Text(
                          _submitting ? "กำลังสมัคร..." : "สมัครสมาชิก",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔹 ย้อนกลับ
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color.fromARGB(255, 0, 162, 177), width: 1.5),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "ย้อนกลับ",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color.fromARGB(255, 0, 162, 177), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
        style: const TextStyle(color: Colors.white),
        keyboardType: isPassword
            ? TextInputType.text
            : (hint.contains('โทร') || hint.toLowerCase().contains('จำนวน') || hint.contains('บัญชี'))
                ? TextInputType.number
                : TextInputType.text,
      ),
    );
  }
}
