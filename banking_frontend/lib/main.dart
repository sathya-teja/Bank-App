import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_shell.dart';
import 'screens/transactions/deposit_screen.dart';
import 'screens/transactions/withdraw_screen.dart';
import 'screens/transactions/transfer_screen.dart';
import 'screens/transactions/history_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BankingApp());
}

class BankingApp extends StatelessWidget {
  const BankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadFromStorage())
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'BankingApp',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: auth.isAuthenticated ? const HomeShell() : const LoginScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/deposit': (context) => const DepositScreen(),
              '/withdraw': (context) => const WithdrawScreen(),
              '/transfer': (context) => const TransferScreen(),
              '/history': (context) => const HistoryScreen(), 
            },
          );
        },
      ),
    );
  }
}
