import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// ===== โมเดล Request =====
class AddLotteryRequest {
  String role;
  int number;

  AddLotteryRequest({required this.role, required this.number});

  Map<String, dynamic> toJson() => {"role": role, "number": number};
}

// ===== โมเดล Response =====
class AddLotteryRespone {
  String message;
  AddLotteryRespone({required this.message});

  factory AddLotteryRespone.fromJson(Map<String, dynamic> json) =>
      AddLotteryRespone(message: json["message"]);
}

class AddlotteryPage extends StatefulWidget {
  const AddlotteryPage({super.key});

  @override
  State<AddlotteryPage> createState() => _AddlotteryPageState();
}

class _AddlotteryPageState extends State<AddlotteryPage> {
  final _qtyCtl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _qtyCtl.dispose();
    super.dispose();
  }

  Future<void> _submitLottery() async {
    final qtyText = _qtyCtl.text.trim();
    if (qtyText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณากรอกจำนวนล็อตเตอรี่")));
      return;
    }

    final req = AddLotteryRequest(role: "admin", number: int.parse(qtyText));

    setState(() => _loading = true);

    try {
      final resp = await http.post(
        Uri.parse(
          "https://lotto-api-production.up.railway.app/api/Admin/add-lottery",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(req.toJson()),
      );

      if (resp.statusCode == 200) {
        final data = AddLotteryRespone.fromJson(jsonDecode(resp.body));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ ${data.message}")));
        Navigator.pop(context, true); // ส่งค่า true กลับไปบอกว่ามีการเพิ่มแล้ว
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ เพิ่มไม่สำเร็จ: ${resp.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF006064),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "เพิ่มล็อตเตอรี่",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
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
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "จำนวนล็อตเตอรี่",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 93, 110),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _qtyCtl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "กรอกจำนวนล็อตเตอรี่",
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: const Color(0xFFEDEDED),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE0E0E0),
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "ยกเลิก",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GradientButton(
                        onTap: _loading ? () {} : _submitLottery,
                        text: _loading ? "กำลังเพิ่ม..." : "เพิ่ม",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ปุ่ม Gradient
class _GradientButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  const _GradientButton({required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF0A8678), Color(0xFF006064)],
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
