import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddlotteryPage extends StatefulWidget {
  const AddlotteryPage({super.key});

  @override
  State<AddlotteryPage> createState() => _AddlotteryPageState();
}

class _AddlotteryPageState extends State<AddlotteryPage> {
  final _qtyCtl = TextEditingController();

  @override
  void dispose() {
    _qtyCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar สีเดียวกับพื้นหลังด้านบน
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
          // ===== การ์ดสีขาวกลางจอ =====
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

                // ช่องกรอกจำนวน
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

                // ปุ่มสองคอลัมน์: ยกเลิก / เพิ่ม
                Row(
                  children: [
                    // ยกเลิก (ปุ่มเทา)
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

                    // เพิ่ม (ปุ่มเขียวไล่เฉด)
                    Expanded(
                      child: _GradientButton(
                        onTap: () {
                          // TODO: ใส่ลอจิกเพิ่มล็อตเตอรี่ของคุณ
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("เพิ่ม ${_qtyCtl.text} รายการ"),
                            ),
                          );
                        },
                        text: "เพิ่ม",
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

// ปุ่มไล่เฉดให้เหมือนในภาพ
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
