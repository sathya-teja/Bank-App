import 'package:flutter/material.dart';
import '../../services/account_service.dart';
import '../../services/transaction_service.dart';
import '../../services/profile_service.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _desc = TextEditingController();
  final _svc = TransactionService();
  final _accountSvc = AccountService();
  final _profileSvc = ProfileService();

  String? _selectedAccountNumber;
  List<dynamic> _accounts = [];
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

    // 🔹 Show toast immediately if not verified
    if (!verified && mounted) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _showToast("Please complete your KYC verification to use Withdraw ❗",
            success: false);
      });
    }
  }

  // 🔹 Bottom toast for warnings/info
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

  // 🔹 Center popup for success/failure
  Future<void> _showPopup(String message, {bool success = true}) async {
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
                BoxShadow(
                    color: Colors.black26, blurRadius: 12, offset: Offset(0, 5))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  size: 64,
                  color: success ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
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
      appBar: AppBar(
        title: const Text("Withdraw"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AbsorbPointer(
          absorbing: !_kycVerified, // 🔹 block UI if KYC not verified
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 🔹 Account selection
                DropdownButtonFormField<String>(
                  value: _selectedAccountNumber,
                  items: _accounts.map<DropdownMenuItem<String>>((acc) {
                    final number = acc['accountNumber']?.toString() ?? 'Unknown';
                    return DropdownMenuItem(
                      value: number,
                      child: Text("A/C: $number"),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setState(() => _selectedAccountNumber = val),
                  decoration: InputDecoration(
                    labelText: 'Select Account',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please select an account'
                      : null,
                ),

                const SizedBox(height: 14),

                // 🔹 Amount
                TextFormField(
                  controller: _amount,
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                  controller: _desc,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // 🔹 Withdraw button
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
                    onPressed: _loading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            if (_selectedAccountNumber == null) return;

                            setState(() => _loading = true);

                            final res = await _svc.withdraw(
                              _selectedAccountNumber!,
                              double.tryParse(_amount.text.trim()) ?? 0.0,
                              description: _desc.text.trim().isEmpty
                                  ? null
                                  : _desc.text.trim(),
                            );

                            setState(() => _loading = false);
                            if (!mounted) return;

                            final success = res['status'] == 'success' ||
                                res['status'] == 200 ||
                                res['status'] == 201;

                            if (success) {
                              _showPopup("Withdrawal successful ✅",
                                  success: true);
                            } else {
                              _showPopup(
                                "Withdrawal failed ❌\n${res['data'] ?? ''}",
                                success: false,
                              );
                            }
                          },
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
                            'Withdraw',
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

/// 🔹 Bottom toast widget
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
      begin: const Offset(0, 1), // start from bottom
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
