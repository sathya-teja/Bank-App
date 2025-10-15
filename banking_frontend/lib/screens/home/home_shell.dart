import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import '../accounts/accounts_list_screen.dart';
import '../profile/my_profile_screen.dart';
import '../transactions/history_screen.dart';
import 'qr_screen.dart'; // 👈 create this later
import 'package:flutter_svg/flutter_svg.dart';


class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  int _index = 0;

  final _tabs = const [
    DashboardScreen(),
    AccountsListScreen(),
    HistoryScreen(),
    MyProfileScreen(),
  ];

  AnimationController? _animController; // ✅ nullable

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
    )..value = 1.0; // ✅ safe starting value
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  Future<void> _onQrPressed() async {
    if (_animController == null) return;

    // ✅ play bounce animation
    await _animController!.reverse();
    await _animController!.forward();

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
      SvgPicture.asset(
        'assets/images/finpay_wordmark.svg',
        height: 36,
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

      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D1B2A),
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
                child: Icon(Icons.person,
                    size: 32, color: Color(0xFF1B998B) ),
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
              title: const Text("Logout",
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                await context.read<AuthProvider>().logout();
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', (_) => false);
              },
            ),
          ],
        ),
      ),

      body: _tabs[_index],

      // ✅ Animated Floating QR button
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 6),
        child: ScaleTransition(
          scale: _animController ?? const AlwaysStoppedAnimation(1.0),
          child: SizedBox(
            height: 58,
            width: 58,
            child: FloatingActionButton(
              onPressed: _onQrPressed,
              backgroundColor: Color(0xFF1B998B) ,
              shape: const CircleBorder(),
              elevation: 6,
              child: const Icon(Icons.qr_code_scanner,
                  size: 28, color: Colors.white),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      // ✅ Bottom nav with notch for QR button
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        elevation: 8,
        color: Colors.white,
        child: SizedBox(
          height: 85,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.dashboard_outlined, "Home", 0),
              _buildNavItem(Icons.account_balance_wallet_outlined,
                  "Accounts", 1),
              const SizedBox(width: 40), // space for QR
              _buildNavItem(Icons.history, "History", 2),
              _buildNavItem(Icons.person_outline, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _index == index;
    final color =
        isSelected ? Color(0xFF1B998B) : Colors.grey.shade600;

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => setState(() => _index = index),
      child: SizedBox(
        width: 64,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
