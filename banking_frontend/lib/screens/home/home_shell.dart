import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import '../accounts/accounts_list_screen.dart';
import '../profile/my_profile_screen.dart';
import '../transactions/history_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _tabs = const [
    DashboardScreen(),
    AccountsListScreen(),
    HistoryScreen(), // ✅ history tab
    MyProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // ✅ Custom bank logo with green shades
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.green.shade100,
              child: Icon(Icons.account_balance,
                  color:Color(0xFF1B998B), size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'BankingApp',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          if (auth.isAdmin)
            IconButton(
              tooltip: 'Admin deposit',
              onPressed: () =>
                  Navigator.of(context).pushNamed('/deposit'),
              icon: const Icon(Icons.savings_outlined),
            ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', (_) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      // ✅ Add left drawer
      drawer: Drawer(
  child: Column(
    children: [
      UserAccountsDrawerHeader(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B2A), // same as BalanceCard gradient
              Color(0xFF1B998B),
            ],
          ),
        ),
        accountName: Text(
          auth.user?['name'] ?? 'User',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        accountEmail: Text(auth.user?['email'] ?? 'No email'),
        currentAccountPicture: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 32, color: Colors.green.shade700),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.account_balance_wallet),
        title: const Text("Accounts"),
        onTap: () => setState(() => _index = 1),
      ),
      ListTile(
        leading: const Icon(Icons.history),
        title: const Text("Transaction History"),
        onTap: () => setState(() => _index = 2),
      ),
      ListTile(
        leading: const Icon(Icons.person_outline),
        title: const Text("My Profile"),
        onTap: () => setState(() => _index = 3),
      ),
      const Spacer(),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text("Logout", style: TextStyle(color: Colors.red)),
        onTap: () async {
          await context.read<AuthProvider>().logout();
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
        },
      ),
    ],
  ),
),

      body: _tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Accounts'),
          NavigationDestination(
              icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
