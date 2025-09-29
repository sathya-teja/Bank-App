import 'package:flutter/material.dart';
import '../../services/account_service.dart';
import '../../services/transaction_service.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _desc = TextEditingController();
  final _svc = TransactionService();
  final _accountSvc = AccountService();

  String? _selectedAccountNumber;
  List<dynamic> _accounts = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await _accountSvc.myAccounts();
    setState(() => _accounts = accounts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deposit Money"),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // 🔹 Select account dropdown or manual entry
                  if (_accounts.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: _selectedAccountNumber,
                      items: _accounts.map<DropdownMenuItem<String>>((acc) {
                        final number =
                            acc['accountNumber']?.toString() ?? 'Unknown';
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.account_balance),
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Please select an account'
                          : null,
                    )
                  else
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Target Account Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                      onChanged: (v) => _selectedAccountNumber = v.trim(),
                      validator: (v) {
                        if ((v ?? '').trim().isEmpty) {
                          return 'Account number is required';
                        }
                        if ((v ?? '').trim().length < 6) {
                          return 'Enter a valid account number';
                        }
                        return null;
                      },
                    ),

                  const SizedBox(height: 16),

                  // 🔹 Amount field
                  TextFormField(
                    controller: _amount,
                    decoration: InputDecoration(
                      labelText: 'Amount (₹)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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

                  const SizedBox(height: 16),

                  // 🔹 Description field
                  TextFormField(
                    controller: _desc,
                    decoration: InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.description_outlined),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔹 Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B998B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _loading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              final accountNumber = _selectedAccountNumber;
                              if (accountNumber == null ||
                                  accountNumber.isEmpty) return;

                              setState(() => _loading = true);
                              final res = await _svc.deposit(
                                accountNumber,
                                double.tryParse(_amount.text.trim()) ?? 0.0,
                                description: _desc.text.trim().isEmpty
                                    ? null
                                    : _desc.text.trim(),
                              );
                              setState(() => _loading = false);

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Status: ${res['status']} • ${res['data']}')),
                              );
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
                              'Deposit',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
