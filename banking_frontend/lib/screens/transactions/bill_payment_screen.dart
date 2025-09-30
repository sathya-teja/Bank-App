import 'package:flutter/material.dart';
import '../../services/account_service.dart';
import '../../services/transaction_service.dart';
import '../../services/profile_service.dart';
import 'receipt_screen.dart';

class BillPaymentScreen extends StatefulWidget {
  const BillPaymentScreen({super.key});

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _billTypeCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _accountSvc = AccountService();
  final _profileSvc = ProfileService();
  final _txService = TransactionService();

  List<dynamic> _accounts = [];
  String? _fromAccountNumber;
  bool _loading = false;
  bool _kycVerified = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _loadProfile();
  }

  Future<void> _loadAccounts() async {
    final accounts = await _accountSvc.myAccounts();
    setState(() => _accounts = accounts);
  }

  Future<void> _loadProfile() async {
    final p = await _profileSvc.myProfile();
    final verified = (p?['kycStatus'] ?? '') == 'verified';
    setState(() => _kycVerified = verified);

    if (!verified && mounted) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _showToast("Please complete your KYC verification to pay bills ❗",
            success: false);
      });
    }
  }

  // 🔹 Toast
  void _showToast(String message, {bool success = true}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        success: success,
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromAccountNumber == null) return;

    setState(() => _loading = true);

    final res = await _txService.payBill(
      accountNumber: _fromAccountNumber!,
      amount: double.tryParse(_amountCtrl.text.trim()) ?? 0.0,
      billType: _billTypeCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (res['status'] == 201 && res['transaction'] != null) {
      final tx = res['transaction'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptScreen(
            tx: {
              ...tx,
              'fromAccount': _fromAccountNumber!,
              'toAccount': _billTypeCtrl.text.trim(),
              'description': _descCtrl.text.trim().isEmpty
                  ? 'Bill Payment'
                  : _descCtrl.text.trim(),
            },
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptScreen(
            tx: {
              'error': res['error'] ?? 'Bill payment failed ❌',
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay Bill"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AbsorbPointer(
          absorbing: !_kycVerified,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 🔹 From Account
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Please select an account' : null,
                ),

                const SizedBox(height: 14),

                // 🔹 Bill Type
                TextFormField(
                  controller: _billTypeCtrl,
                  decoration: InputDecoration(
                    labelText: 'Bill Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.receipt_long),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Bill type required' : null,
                ),

                const SizedBox(height: 14),

                // 🔹 Amount
                TextFormField(
                  controller: _amountCtrl,
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.currency_rupee),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Amount is required';
                    }
                    final amt = double.tryParse(v);
                    if (amt == null || amt <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // 🔹 Description
                TextFormField(
                  controller: _descCtrl,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.description_outlined),
                  ),
                ),

                const SizedBox(height: 22),

                // 🔹 Pay Bill Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B998B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Pay Bill',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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

/// 🔹 Toast widget
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
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _offset = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.success ? Icons.check_circle : Icons.warning_amber,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
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

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
