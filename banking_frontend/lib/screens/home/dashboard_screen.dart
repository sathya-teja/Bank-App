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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

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
          Text('Quick Actions', style: textTheme.titleMedium),
          const SizedBox(height: 16),

          Row(
            children: [
              if (auth.isAdmin)
                Expanded(
                  child: _buildActionCard(
                    context: context,
                    icon: Icons.savings_outlined,
                    label: "Deposit",
                    onTap: () => Navigator.pushNamed(context, '/deposit'),
                    colorScheme: colorScheme,
                    isDark: isDark,
                  ),
                ),
              if (auth.isAdmin) const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context: context,
                  icon: Icons.arrow_circle_down_outlined,
                  label: "Withdraw",
                  onTap: () => Navigator.pushNamed(context, '/withdraw'),
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context: context,
                  icon: Icons.swap_horiz_rounded,
                  label: "Transfer",
                  onTap: () => Navigator.pushNamed(context, '/transfer'),
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🔹 Bill Payment action
          _buildActionCard(
            context: context,
            icon: Icons.receipt_long_outlined,
            label: "Pay Bill",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BillPaymentScreen()),
              );
            },
            colorScheme: colorScheme,
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          // 🔹 Admin-only KYC card
          if (auth.isAdmin)
            _buildActionCard(
              context: context,
              icon: Icons.verified_user,
              label: "KYC Requests",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const KycRequestsScreen()),
                );
              },
              colorScheme: colorScheme,
              isDark: isDark,
            ),

          const SizedBox(height: 28),

          // 🔹 Accounts section
          Text('Accounts', style: textTheme.titleMedium),
          const SizedBox(height: 16),
          ..._accounts.map((a) => _buildAccountCard(context, a)),
        ],
      ),
    );
  }

  // 🔹 Action Card Widget (with theme-aware colors; bright in light, tinted in dark)
  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Use bright surface in light mode, and a soft tint based on primary in dark mode.
    final Color cardColor = isDark
        ? colorScheme.primary.withOpacity(0.12) // subtle teal tint in dark mode
        : colorScheme.surface; // usual white in light mode

    return Card(
      elevation: 3,
      color: cardColor,
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
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(icon, color: colorScheme.primary, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Account Card Widget (clickable → Goals screen)
  Widget _buildAccountCard(BuildContext context, dynamic account) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final balance = ((account['balance'] ?? 0) / 100.0).toStringAsFixed(2);
    final type = (account['type'] ?? 'SAV').toString().toUpperCase();
    final number = account['accountNumber']?.toString() ?? 'Unknown';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: colorScheme.surface, // keeps account cards readable
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
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(Icons.account_balance_wallet, color: colorScheme.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "A/C: $number",
                      style: textTheme.bodyMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Type: $type",
                      style: textTheme.bodySmall?.copyWith(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹ $balance",
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Goals →",
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
