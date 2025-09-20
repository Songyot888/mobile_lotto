import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/page/buttom_nav.dart';

class EditprofilePage extends StatefulWidget {
  const EditprofilePage({super.key});

  @override
  State<EditprofilePage> createState() => _EditprofilePageState();
}

class _EditprofilePageState extends State<EditprofilePage> {
  // STEP 1: สถานะผู้ใช้ + ตัวแปรฟอร์ม
  User? _user;
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _bankNameCtl = TextEditingController();
  final _bankNumberCtl = TextEditingController();
  bool _saving = false;

  // STEP 2: เริ่มต้น → ลองโหลดจาก Session
  @override
  void initState() {
    super.initState();
    _initUser(); // โหลดจาก Session
  }

  // STEP 3: รับ arguments จาก Route (ถ้ามี) แล้วเติมค่าลงฟอร์ม
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is User) {
      _user = args;
      _hydrateControllers(); // เติมค่าลงช่องกรอก
    }
    setState(() {});
  }

  Future<void> _initUser() async {
    final u = await Session.getUser();
    if (!mounted) return;
    // ถ้ายังไม่มีจาก args ค่อยใช้ของ Session
    if (_user == null && u != null) {
      setState(() {
        _user = u;
        _hydrateControllers();
      });
    }
  }

  // STEP 4: เติมค่าจาก _user ลง controller
  void _hydrateControllers() {
    _nameCtl.text = _user?.fullName ?? '';
    _emailCtl.text = _user?.email ?? ''; // ส่วนใหญ่ email มักไม่ให้แก้
    _phoneCtl.text = _user?.phone ?? '';
    _bankNameCtl.text = _user?.bankName ?? '';
    _bankNumberCtl.text = _user?.bankNumber ?? '';
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _phoneCtl.dispose();
    _bankNameCtl.dispose();
    _bankNumberCtl.dispose();
    super.dispose();
  }

  // STEP 5: ตัวตรวจความถูกต้อง
  String? _req(String? v, {String label = 'ข้อมูล'}) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอก$label';
    return null;
  }

  String? _email(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'กรุณากรอกอีเมล';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
    if (!ok) return 'อีเมลไม่ถูกต้อง';
    return null;
  }

  String? _phone(String? v) {
    final s = v?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (s.isEmpty) return 'กรุณากรอกเบอร์';
    if (s.length < 9) return 'รูปแบบเบอร์ไม่ถูกต้อง';
    return null;
  }

  // STEP 6: กดบันทึก → validate → รวมค่าลง _user → (TODO: ยิง API) → pop(result)
  Future<void> _save() async {
    if (_user == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      // รวมค่าจากฟอร์มกลับเข้า _user (ถ้าโมเดลเป็น mutable)
      _user!
        ..fullName = _nameCtl.text.trim()
        ..phone = _phoneCtl.text.trim()
        ..bankName = _bankNameCtl.text.trim()
        ..bankNumber = _bankNumberCtl.text.trim();
      // ถ้าต้องแก้ email ด้วย ก็เปิดใช้บรรทัดด้านล่างตามนโยบายระบบ
      // _user!..email = _emailCtl.text.trim();

      // TODO: ยิง API อัปเดตไปเซิร์ฟเวอร์ของคุณที่นี่
      // final updated = await Api.updateProfile(...);
      // _user = updated;

      // (ทางเลือก) เซฟลง Session ถ้ามีเมธอดรองรับ
      // await Session.setUser(_user!);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')));
      Navigator.pop(context, _user); // ส่งผลลัพธ์กลับหน้าเดิม
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // STEP 7: UI หลัก
  @override
  Widget build(BuildContext context) {
    final balanceText =
        '฿ ${((_user?.balance ?? 0) as num).toStringAsFixed(2)}'; // อย่าใส่ใน const Text

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF006064),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "แก้ไขข้อมูลสมาชิก",
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
              balanceText, // ตัวแปร → ห้ามใช้ const Text กับตัวแปร
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

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
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.6),
                    width: 1,
                  ),
                ),

                // STEP 8: ถ้ามี _user → แสดงฟอร์ม, ถ้าไม่มี → แจ้งไม่พบ
                child: _user == null
                    ? const Text(
                        "ไม่พบข้อมูลผู้ใช้",
                        style: TextStyle(color: Colors.white),
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _field(
                              controller: _nameCtl,
                              label: 'ชื่อ-นามสกุล',
                              icon: Icons.person_outline,
                              validator: (v) => _req(v, label: 'ชื่อ-นามสกุล'),
                              textInputAction: TextInputAction.next,
                            ),
                            _field(
                              controller: _emailCtl,
                              label: 'อีเมล',
                              icon: Icons.alternate_email,
                              validator: _email,
                              keyboardType: TextInputType.emailAddress,
                              readOnly:
                                  true, // ถ้าอยากให้แก้ได้ก็เปลี่ยนเป็น false
                              textInputAction: TextInputAction.next,
                            ),
                            _field(
                              controller: _phoneCtl,
                              label: 'เบอร์โทร',
                              icon: Icons.phone_outlined,
                              validator: _phone,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textInputAction: TextInputAction.next,
                            ),
                            _field(
                              controller: _bankNameCtl,
                              label: 'ธนาคาร',
                              icon: Icons.account_balance_outlined,
                              validator: (v) => _req(v, label: 'ธนาคาร'),
                              textInputAction: TextInputAction.next,
                            ),
                            _field(
                              controller: _bankNumberCtl,
                              label: 'เลขบัญชี',
                              icon: Icons.credit_card_outlined,
                              validator: (v) => _req(v, label: 'เลขบัญชี'),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textInputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00BFA5),
                                    ),
                                    onPressed: _saving ? null : _save,
                                    child: _saving
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('บันทึก'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD32F2F),
                                      foregroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    onPressed: _saving
                                        ? null
                                        : () => Navigator.pop(context),
                                    child: const Text('ยกเลิก'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ),
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

  // ชุดสร้าง TextFormField ให้มีหน้าตาเข้ากับการ์ด
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    TextInputAction? textInputAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.45), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        readOnly: readOnly,
        textInputAction: textInputAction,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
