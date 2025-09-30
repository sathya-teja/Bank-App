import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/account_service.dart';
import '../../widgets/balance_card.dart';
import '../profile/kyc_requests_screen.dart';
import '../transactions/bill_payment_screen.dart';
import '../transactions/goals_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _accountSvc = AccountService();

  double _totalBalance = 0;
  List<dynamic> _accounts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final accounts = await _accountSvc.myAccounts();
    double total = 0;
    for (final a in accounts) {
      final balPaise = (a['balance'] ?? 0) as int;
      total += balPaise / 100.0;
    }
    setState(() {
      _accounts = accounts;
      _totalBalance = total;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (_loading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔹 Total Balance card
          BalanceCard(
            title: 'Total Balance',
            balance: _totalBalance,
            currency: '₹',
          ),

          const SizedBox(height: 24),

          // 🔹 Quick Actions
          Text('Quick Actions',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),

          Row(
            children: [
              if (auth.isAdmin)
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.savings_outlined,
                    label: "Deposit",
                    onTap: () => Navigator.pushNamed(context, '/deposit'),
                  ),
                ),
              if (auth.isAdmin) const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.arrow_circle_down_outlined,
                  label: "Withdraw",
                  onTap: () => Navigator.pushNamed(context, '/withdraw'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.swap_horiz_rounded,
                  label: "Transfer",
                  onTap: () => Navigator.pushNamed(context, '/transfer'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🔹 Bill Payment action
          _buildActionCard(
            icon: Icons.receipt_long_outlined,
            label: "Pay Bill",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BillPaymentScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // 🔹 Admin-only KYC card
          if (auth.isAdmin)
            _buildActionCard(
              icon: Icons.verified_user,
              label: "KYC Requests",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const KycRequestsScreen()),
                );
              },
            ),

          const SizedBox(height: 28),

          // 🔹 Accounts section
          Text('Accounts', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ..._accounts.map((a) => _buildAccountCard(a)),
        ],
      ),
    );
  }

  // 🔹 Action Card Widget (with consistent green theme)
  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE6F4F1),
                child: Icon(icon, color: const Color(0xFF1B998B), size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Account Card Widget (clickable → Goals screen)
  Widget _buildAccountCard(dynamic account) {
    final balance = ((account['balance'] ?? 0) / 100.0).toStringAsFixed(2);
    final type = (account['type'] ?? 'SAV').toString().toUpperCase();
    final number = account['accountNumber']?.toString() ?? 'Unknown';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GoalsScreen(accountNumber: number),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFE6F4F1),
                child: const Icon(Icons.account_balance_wallet,
                    color: Color(0xFF1B998B), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("A/C: $number",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text("Type: $type",
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("₹ $balance",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text("Goals →",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
