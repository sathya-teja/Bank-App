import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/account_service.dart';
import '../transactions/transfer_screen.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({Key? key}) : super(key: key);

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  bool _isMyQr = true;
  Future<List<dynamic>>? _accounts;
  Map<String, dynamic>? _selectedAccount;
  bool _navigated = false; // ✅ prevent duplicate navigation

  @override
  void initState() {
    super.initState();
    _accounts = AccountService().myAccounts();
  }

  void _toggleTab(bool myQr) {
    setState(() {
      _isMyQr = myQr;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Payments"),
        centerTitle: true,
        backgroundColor: Colors.green.shade600,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildTabButton("My QR", true),
                _buildTabButton("Scan & Pay", false),
              ],
            ),
          ),

          // Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _isMyQr ? _buildMyQr(context) : _buildScanner(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isMyQr) {
    final selected = _isMyQr == isMyQr;
    return Expanded(
      child: GestureDetector(
        onTap: () => _toggleTab(isMyQr),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.green.shade600 : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// --- My QR Section ---
  Widget _buildMyQr(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fullName = auth.user?['name'] ?? "Unknown";

    return FutureBuilder<List<dynamic>>(
      future: _accounts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No account found"));
        }

        final accounts = snapshot.data!;
        _selectedAccount ??= accounts.first;

        final accountNumber = _selectedAccount!['accountNumber'];
        final qrData = jsonEncode({
          "toAccount": accountNumber, // ✅ consistent key
          "name": fullName,
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Account selector list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: accounts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final acc = accounts[index];
                  final isSelected =
                      acc['accountNumber'] == _selectedAccount!['accountNumber'];

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAccount = acc);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  Colors.green.shade600,
                                  Colors.green.shade400
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "A/C: ${acc['accountNumber']}",
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                acc['type'] ?? "Savings",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.account_balance_wallet_outlined,
                            color:
                                isSelected ? Colors.white : Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // QR Code
              QrImageView(
                data: qrData,
                size: 220,
                backgroundColor: Colors.white,
              ),

              const SizedBox(height: 20),
              Text(fullName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text("A/C: $accountNumber",
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),

              const SizedBox(height: 30),
              const Icon(Icons.security, color: Colors.green),
              const Text("Secure UPI-like payment with QR"),
            ],
          ),
        );
      },
    );
  }

  /// --- Scan & Pay Section ---
  Widget _buildScanner() {
    return Column(
      children: [
        Expanded(
          child: MobileScanner(
            fit: BoxFit.cover,
            onDetect: (capture) {
              if (_navigated) return; // ✅ avoid duplicate navigation
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  try {
                    final decoded = jsonDecode(barcode.rawValue!);

                    if (decoded is Map &&
                        decoded['toAccount'] != null &&
                        decoded['name'] != null) {
                      _navigated = true;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransferScreen(
                            toAccount: decoded['toAccount'],
                            recipientName: decoded['name'],
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Invalid QR code"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Could not read QR Code"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  break;
                }
              }
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green.shade50,
          child: Column(
            children: const [
              Icon(Icons.qr_code_scanner, size: 50, color: Colors.green),
              SizedBox(height: 10),
              Text(
                "Point your camera at a QR code to pay",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        )
      ],
    );
  }
}
