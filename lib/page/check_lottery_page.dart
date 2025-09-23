import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_lotto/core/session.dart';
import 'package:mobile_lotto/model/response/login_res_post.dart';
import 'package:mobile_lotto/model/response/my_lottory_res.dart';
import 'package:mobile_lotto/page/buttom_nav.dart';

class CheckLotteryPage extends StatefulWidget {
  final User? user;
  const CheckLotteryPage({super.key, this.user});

  @override
  State<CheckLotteryPage> createState() => _CheckLotteryPageState();
}

class _CheckLotteryPageState extends State<CheckLotteryPage> {
  User? _user;
  List<MyLottoryRes> mylotto = [];
  bool _loadedOnce = false;
  VoidCallback? _userListener;

  final Set<int> _claimedOids = {};
  final Set<int> _processingClaims = {};
  final Set<int> _checkedOids = {};
  final Set<int> _winnersNotClaimed = {};

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _userListener = () {
      if (!mounted) return;
      setState(() {
        _user = Session.currentUser.value;
      });
    };
    Session.currentUser.addListener(_userListener!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is User) {
      _user = args;
      _loadMylottory();
    }
    setState(() {});
  }

  Future<void> _bootstrap() async {
    await _loadFromSession();
    await _loadMylottory();
  }

  Future<void> _loadFromSession() async {
    final u = await Session.getUser();
    if (!mounted) return;
    if (u != null) {
      setState(() => _user = u);
    } else {
      setState(() {});
    }
  }

  Future<void> _loadMylottory() async {
    if (!mounted || _loadedOnce || _user?.uid == null) return;

    try {
      final uri = Uri.parse(
        'https://lotto-api-production.up.railway.app/api/User/MyLotto/${_user?.uid}',
      );

      final res = await http.get(uri);
      log("MyLotto status: ${res.statusCode}");
      log(res.body);

      if (!mounted) return;

      if (res.statusCode == 200 &&
          res.body.isNotEmpty &&
          res.body.trim() != '[]') {
        final parsed = myLottoryResFromJson(res.body);
        setState(() {
          mylotto = parsed;
          _loadedOnce = true;
        });
        log('MyLotto parsed count: ${parsed.length}');
      } else {
        setState(() {
          mylotto = [];
          _loadedOnce = true;
        });
        log('MyLotto: no data for uid=${_user!.uid}');
      }
    } catch (e, st) {
      log('MyLotto error: $e\n$st');
      if (!mounted) return;
      setState(() => mylotto = []);
    }
  }

  Future<void> _onCheckPressed({
    required int oid,
    required int lid,
    required String number,
  }) async {
    if (!mounted || _user?.uid == null) return;

    setState(() {
      _checkedOids.add(oid);
    });

    try {
      final memberId = _user!.uid;
      final response = await http.post(
        Uri.parse('https://lotto-api-production.up.railway.app/api/User/check'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'memberId': memberId, 'lid': lid}),
      );

      log('Check API response status: ${response.statusCode}');
      log('Check API response body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode != 200 || response.body.isEmpty) {
        throw Exception('Failed to get a valid response from the server.');
      }

      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic> &&
          body['message'] == 'ยังไม่มีการออกรางวัล') {
        _showResultDialog(
          isWinner: null,
          number: number,
          prize: 0,
          onClaim: null,
        );
        setState(() {
          _checkedOids.remove(oid);
        });
        return;
      }

      bool isWin = false;
      int prize = 0;

      if (body is Map<String, dynamic>) {
        final dynamicWin = body['isWin'] ?? body['win'] ?? body['isWinner'];
        if (dynamicWin is bool) {
          isWin = dynamicWin;
        }

        final dynamicPrize =
            body['prize'] ?? body['payout'] ?? body['payoutRate'] ?? 0;
        if (dynamicPrize is num) {
          prize = dynamicPrize.round();
        }

        if (dynamicWin == null) {
          isWin = prize > 0;
        }
      } else if (body is bool) {
        isWin = body;
      }

      if (isWin) {
        setState(() {
          _winnersNotClaimed.add(oid);
        });
        _showResultDialog(
          isWinner: true,
          number: number,
          prize: prize,
          onClaim: () => _claimPrize(oid, prize),
        );
      } else {
        _showResultDialog(
          isWinner: false,
          number: number,
          prize: 0,
          onClaim: null,
        );
      }
    } catch (e, st) {
      log('Error checking lottery: $e\n$st');
      if (!mounted) return;
      setState(() {
        _checkedOids.remove(oid);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่')),
      );
    }
  }

  void _showResultDialog({
    required bool? isWinner,
    required String number,
    required int prize,
    VoidCallback? onClaim,
  }) {
    String title;
    String message;
    IconData icon;
    Color iconColor;

    if (isWinner == null) {
      title = 'ยังไม่มีผลรางวัล';
      message = 'กรุณาลองใหม่อีกครั้ง';
      icon = Icons.hourglass_empty;
      iconColor = Colors.orange;
    } else if (isWinner) {
      title = 'ยินดีด้วย!';
      message = 'คุณถูกรางวัล ${_formatPrize(prize)} บาท';
      icon = Icons.sentiment_satisfied_alt;
      iconColor = Colors.green;
    } else {
      title = 'น่าเสียดาย!';
      message = 'คุณไม่ถูกรางวัล';
      icon = Icons.sentiment_dissatisfied;
      iconColor = Colors.red;
    }

    showGeneralDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierLabel: 'result',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.82,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: iconColor, size: 64),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(message),
                  if (isWinner != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        number,
                        style: const TextStyle(
                          letterSpacing: 4,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            side: const BorderSide(color: Colors.black26),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('ปิด'),
                        ),
                      ),
                      if (isWinner == true && onClaim != null) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                              onClaim();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('ขึ้นเงินรางวัล'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: child,
      ),
    );
  }

  void _showClaimSuccessDialog() {
    showGeneralDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierLabel: 'claim',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.78,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 64),
                  const SizedBox(height: 12),
                  const Text(
                    'ขึ้นรางวัลสำเร็จ',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('ปิด'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: child,
      ),
    );
  }

  Future<void> _claimPrize(int oid, int prize) async {
    if (!mounted || _user?.uid == null) return;
    final memberId = _user!.uid;

    if (_processingClaims.contains(oid)) {
      return;
    }

    setState(() {
      _processingClaims.add(oid);
    });

    try {
      final claimRes = await http.post(
        Uri.parse('https://lotto-api-production.up.railway.app/api/User/claim'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'memberId': memberId, 'orderId': oid}),
      );

      log('claim status: ${claimRes.statusCode}');
      log(claimRes.body);

      if (!mounted) return;

      if (claimRes.statusCode >= 200 && claimRes.statusCode < 300) {
        setState(() {
          _claimedOids.add(oid);
          _winnersNotClaimed.remove(oid);
        });

        try {
          final body = jsonDecode(claimRes.body);
          if (body is Map<String, dynamic>) {
            final walletDyn =
                body['wallet'] ?? body['balance'] ?? body['newWallet'];
            if (walletDyn is num) {
              await Session.updateBalance(walletDyn.toDouble());
            }
          }
        } catch (_) {}

        _showClaimSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ขึ้นรางวัลไม่สำเร็จ กรุณาลองอีกครั้ง'),
            backgroundColor: Color(0xFFFF5722),
          ),
        );
      }
    } catch (e, st) {
      log('claim error: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาดในการขึ้นรางวัล'),
          backgroundColor: Color(0xFFFF5722),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingClaims.remove(oid);
        });
      }
    }
  }

  String _formatPrize(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final pos = s.length - i - 1;
      if (pos % 3 == 0 && pos != 0) buf.write(',');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        "ตรวจล็อตเตอรี่",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _BalancePill(amount: _user?.balance ?? 0),
                  ],
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    "ตรวจล็อตเตอรี่",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: mylotto
                      .map(
                        (n) => _CheckCard(
                          number: n.number,
                          oid: n.oid,
                          status: n.status,
                          isChecked: _checkedOids.contains(n.oid),
                          isClaimed: _claimedOids.contains(n.oid),
                          isProcessingClaim: _processingClaims.contains(n.oid),
                          isWinnerNotClaimed: _winnersNotClaimed.contains(
                            n.oid,
                          ),
                          onCheck: () => _onCheckPressed(
                            oid: n.oid,
                            lid: n.lotteryId,
                            number: n.number,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 1,
        routeNames: const ['/home', '/buy', '/wallet', '/member'],
      ),
    );
  }

  @override
  void dispose() {
    if (_userListener != null) {
      Session.currentUser.removeListener(_userListener!);
    }
    super.dispose();
  }
}

// ---------------- Supporting Widgets ----------------

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
          const Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            amount.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckCard extends StatelessWidget {
  final String number;
  final int oid;
  final bool? status;
  final bool isChecked;
  final bool isClaimed;
  final bool isProcessingClaim;
  final bool isWinnerNotClaimed;
  final VoidCallback onCheck;

  const _CheckCard({
    required this.number,
    required this.oid,
    this.status,
    required this.isChecked,
    required this.isClaimed,
    required this.isProcessingClaim,
    required this.isWinnerNotClaimed,
    required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    String buttonText = "ตรวจล็อตเตอรี่";
    Color buttonColor = const Color(0xFF2E7D32);
    bool isEnabled = true;

    if (isClaimed) {
      buttonText = "ขึ้นเงินแล้ว";
      buttonColor = Colors.grey;
      isEnabled = false;
    } else if (isProcessingClaim) {
      buttonText = "กำลังขึ้นเงิน...";
      buttonColor = Colors.orange;
      isEnabled = false;
    } else if (status != null) {
      buttonText = "ตรวจแล้ว";
      buttonColor = Colors.blueGrey;
      isEnabled = false;
    } else if (isWinnerNotClaimed) {
      buttonText = "ถูกรางวัล";
      buttonColor = Colors.green;
      isEnabled = false;
    } else if (isChecked) {
      buttonText = "ตรวจแล้ว (ไม่ถูกรางวัล)";
      buttonColor = Colors.blueGrey;
      isEnabled = false;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE082),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    letterSpacing: 4,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isEnabled ? onCheck : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              elevation: 0,
              disabledBackgroundColor: buttonColor.withOpacity(0.7),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
