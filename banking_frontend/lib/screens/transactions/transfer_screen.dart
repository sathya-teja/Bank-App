import 'package:flutter/material.dart';
import '../../services/account_service.dart';
import '../../services/transaction_service.dart';
import '../../services/profile_service.dart';
import 'receipt_screen.dart'; // 👈 same folder

class TransferScreen extends StatefulWidget {
  final String? toAccount;      // from QR
  final String? recipientName;  // from QR

  const TransferScreen({
    super.key,
    this.toAccount,
    this.recipientName,
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _toAccountNumber = TextEditingController();
  final _desc = TextEditingController();
  final _svc = TransactionService();
  final _accountSvc = AccountService();
  final _profileSvc = ProfileService();

  String? _fromAccountNumber;
  List<dynamic> _accounts = [];
  bool _loading = false;
  bool _kycVerified = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _loadProfile();

    // Prefill if opened from QR
    if (widget.toAccount != null) {
      _toAccountNumber.text = widget.toAccount!;
    }
    if (widget.recipientName != null) {
      _desc.text = "Paying ${widget.recipientName}";
    }
  }

  Future<void> _loadAccounts() async {
    final accounts = await _accountSvc.myAccounts();
    if (!mounted) return;
    setState(() => _accounts = accounts);
  }

  Future<void> _loadProfile() async {
    final p = await _profileSvc.myProfile();
    if (!mounted) return;
    final verified = (p?['kycStatus'] ?? '') == 'verified';
    setState(() => _kycVerified = verified);

    if (!verified) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _showToast("Please complete your KYC verification to use Transfer ❗",
            success: false);
      });
    }
  }

  void _showToast(String message, {bool success = true}) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    final entry = OverlayEntry(
      builder: (_) => _ToastWidget(message: message, success: success),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  Future<void> _showPopup(String message, {bool success = true}) async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 5))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(success ? Icons.check_circle : Icons.error,
                    size: 64, color: success ? Colors.green : Colors.red),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transfer"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AbsorbPointer(
          absorbing: !_kycVerified,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _fromAccountNumber,
                  items: _accounts.map<DropdownMenuItem<String>>((acc) {
                    final number = acc['accountNumber']?.toString() ?? 'Unknown';
                    return DropdownMenuItem(
                      value: number,
                      child: Text("From A/C: $number"),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _fromAccountNumber = val),
                  decoration: InputDecoration(
                    labelText: 'From Account',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Please select an account' : null,
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _toAccountNumber,
                  decoration: InputDecoration(
                    labelText: 'To Account Number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.arrow_forward),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Destination account is required';
                    if (v.trim().length < 6) return 'Enter a valid account number';
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.currency_rupee),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Amount is required';
                    final amt = double.tryParse(v);
                    if (amt == null || amt <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _desc,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.description_outlined),
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B998B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _loading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            if (_fromAccountNumber == null) return;

                            final amt = double.tryParse(_amount.text.trim()) ?? 0.0;

                            setState(() => _loading = true);
                            final res = await _svc.transfer(
                              _fromAccountNumber!,
                              _toAccountNumber.text.trim(),
                              amt,
                              description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
                            );
                            setState(() => _loading = false);
                            if (!mounted) return;

                            final status = res['status'] as int?;
                            final data = res['data'];

                            if (status == 201 && data is Map) {
                              // data = debitTransaction from server (amount in paise)
                              final receipt = <String, dynamic>{
                                'status': 201, // ✅ so the receipt marks success
                                '_id': data['_id'],
                                'createdAt': data['createdAt'],
                                'amount': (data['amount'] is num)
                                    ? (data['amount'] )
                                    : amt, // fallback
                                'description': data['description'] ?? _desc.text.trim(),
                                'fromAccount': _fromAccountNumber!,
                                'toAccount': _toAccountNumber.text.trim(),
                              };

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReceiptScreen(tx: receipt),
                                ),
                              );
                            } else {
                              final errorText = (data is Map && data['error'] != null)
                                  ? data['error'].toString()
                                  : 'Transaction failed';
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReceiptScreen(tx: {
                                    'status': status ?? 400,
                                    'error': errorText,
                                    'fromAccount': _fromAccountNumber ?? '-',
                                    'toAccount': _toAccountNumber.text.trim(),
                                    'amount': amt,
                                    'description': _desc.text.trim(),
                                  }),
                                ),
                              );
                            }
                          },
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Transfer',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final bool success;
  const _ToastWidget({required this.message, required this.success});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _offset = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 60,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _offset,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.success ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.success ? Icons.check_circle : Icons.warning_amber, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}