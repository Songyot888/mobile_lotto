import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ⬇️ ปรับให้ตรงกับโปรเจกต์ของคุณ
import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
// import 'package:mobile_lotto/model/response/ran_result_res_post.dart'; // ไม่ได้ใช้งานแล้ว

class RandomDrawPage extends StatefulWidget {
  const RandomDrawPage({super.key});

  @override
  State<RandomDrawPage> createState() => _RandomDrawPageState();
}

class _RandomDrawPageState extends State<RandomDrawPage> {
  // State variables for displaying prize numbers
  String prize1 = "------", prize2 = "------", prize3 = "------";
  String last3 = "---", last2 = "--";

  // State variables for displaying payout amounts
  String payout1 = "-", payout2 = "-", payout3 = "-";
  String payoutLast3Each = "-", payoutLast2Each = "-";

  bool _loading = false;
  String? _error;
  User? _user;
  bool _noResults = false; // Flag for when there are no results yet

  @override
  void initState() {
    super.initState();
    // Initialize user data and fetch initial prize results
    _initializeAndFetch();
  }

  Future<void> _initializeAndFetch() async {
    _user = await Session.getUser();
    // Fetch the latest results when the page loads
    await _fetchResults();
  }

  // --- 1. Function to trigger a draw based on purchases ---
  Future<void> _drawFromPurchases() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uid = _getUid(_user);
      if (uid == null) throw Exception("ไม่พบข้อมูลผู้ใช้");

      final uri = Uri.parse(
        "https://lotto-api-production.up.railway.app/api/Admin/result-Lotteryandorder",
      );

      final resp = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"uid": uid}),
      );

      if (resp.statusCode == 200) {
        // After a successful draw, fetch the new results to update the UI
        await _fetchResults();
      } else {
        throw Exception("Server Error: ${resp.statusCode} - ${resp.body}");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = "เกิดข้อผิดพลาดในการสุ่มจากการซื้อ: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- 2. Function to trigger a draw from all tickets ---
  Future<void> _drawFromAll() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uid = _getUid(_user);
      if (uid == null) throw Exception("ไม่พบข้อมูลผู้ใช้");

      final uri = Uri.parse(
        "https://lotto-api-production.up.railway.app/api/Admin/result-allLottery",
      );

      final resp = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"uid": uid}),
      );

      if (resp.statusCode == 200) {
        // After a successful draw, fetch the new results to update the UI
        await _fetchResults();
      } else {
        throw Exception("Server Error: ${resp.statusCode} - ${resp.body}");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = "เกิดข้อผิดพลาดในการสุ่มจากทั้งหมด: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- 3. New function to fetch and display prize results ---
  Future<void> _fetchResults() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
      _noResults = false; // Reset flag on new fetch
    });
    try {
      final uri = Uri.parse(
        "https://lotto-api-production.up.railway.app/api/User/result",
      );

      final resp = await http.get(uri);

      if (resp.statusCode == 200) {
        final decodedData = jsonDecode(resp.body);
        final results = decodedData['result'] as List;

        if (results.isEmpty) {
          // If the results list is empty, it means prizes are not drawn yet
          setState(() {
            _noResults = true;
            // Reset display values
            prize1 = "------";
            prize2 = "------";
            prize3 = "------";
            last3 = "---";
            last2 = "--";
            payout1 = "-";
            payout2 = "-";
            payout3 = "-";
            payoutLast3Each = "-";
            payoutLast2Each = "-";
          });
        } else if (results.length >= 5) {
          // Update the UI state with the fetched data
          setState(() {
            prize1 = results[0]['amount'];
            payout1 = _money(results[0]['payoutRate']);

            prize2 = results[1]['amount'];
            payout2 = _money(results[1]['payoutRate']);

            prize3 = results[2]['amount'];
            payout3 = _money(results[2]['payoutRate']);

            last3 = results[3]['amount'];
            payoutLast3Each = _money(results[3]['payoutRate']);

            last2 = results[4]['amount'];
            payoutLast2Each = _money(results[4]['payoutRate']);
          });
          log("Successfully fetched user results!");
        } else {
          throw Exception("รูปแบบข้อมูลผลรางวัลไม่ถูกต้อง");
        }
      } else {
        throw Exception("Server Error: ${resp.statusCode} - ${resp.body}");
      }
    } catch (e) {
      if (!mounted) return;
      log("Exception when fetching user results: $e");
      setState(() => _error = "ไม่สามารถดึงผลรางวัลได้: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- Helper Functions ---

  /// Safely gets the user ID.
  int? _getUid(User? u) {
    if (u == null) return null;
    try {
      final v = (u as dynamic).uid;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
    } catch (_) {}
    return null;
  }

  /// Formats a number as a currency string (e.g., 1000000 -> "1,000,000").
  String _money(num n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF006064), Color(0xFF00838F), Color(0xFF006064)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- Header ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "สุ่มผลรางวัล",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    // Refresh Button
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _loading ? null : _fetchResults,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // --- Control Buttons ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text("สุ่มจากการซื้อ"),
                        onPressed: _loading ? null : _drawFromPurchases,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF00796B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.all_inclusive),
                        label: const Text("สุ่มจากทั้งหมด"),
                        onPressed: _loading ? null : _drawFromAll,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFFC2185B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // --- Main Content (Results Display) ---
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "เกิดข้อผิดพลาด:\n$_error",
                            style: const TextStyle(color: Colors.yellowAccent),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : _noResults
                    ? const Center(
                        child: Text(
                          "ยังไม่ออกผลรางวัล",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                18,
                                16,
                                22,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 1.4,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "ผลรางวัลประจำงวด",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      height: 1.3,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _line("รางวัลที่ 1", prize1, payout1),
                                  _line("รางวัลที่ 2", prize2, payout2),
                                  _line("รางวัลที่ 3", prize3, payout3),
                                  _line(
                                    "เลขท้าย 3 ตัว",
                                    last3,
                                    payoutLast3Each,
                                  ),
                                  _line(
                                    "เลขท้าย 2 ตัว",
                                    last2,
                                    payoutLast2Each,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Helper for displaying a prize line ---
  Widget _line(String title, String number, String money) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "เงินรางวัล ($money)",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
