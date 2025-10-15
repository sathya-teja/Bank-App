// lib/main.dart
// Updated to load persisted theme before runApp and wire ThemeProvider.
// Paste this file into your project (overwrite existing main.dart).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Your existing imports (keep paths as they are in your project)
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';

// New ThemeProvider import (file I'll provide next)
import 'providers/theme_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/home/home_shell.dart';
import 'screens/transactions/deposit_screen.dart';
import 'screens/transactions/withdraw_screen.dart';
import 'screens/transactions/transfer_screen.dart';
import 'screens/transactions/history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted theme preference before building the app to avoid theme flash.
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? savedTheme = prefs.getString('themeMode'); // 'light' | 'dark' | 'system' | null

  ThemeMode startingMode;
  if (savedTheme == 'light') {
    startingMode = ThemeMode.light;
  } else if (savedTheme == 'dark') {
    startingMode = ThemeMode.dark;
  } else {
    startingMode = ThemeMode.system;
  }

  runApp(BankingApp(
    startingMode: startingMode,
    prefs: prefs,
  ));
}

class BankingApp extends StatelessWidget {
  final ThemeMode startingMode;
  final SharedPreferences prefs;

  const BankingApp({
    super.key,
    required this.startingMode,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Your existing AuthProvider (preserved)
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadFromStorage()),

        // ThemeProvider: a new provider that persists selection to SharedPreferences.
        // I'll send the full provider file next at lib/providers/theme_provider.dart
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(initialMode: startingMode, prefs: prefs),
        ),
      ],
      // Use Consumer2 so we can access both AuthProvider and ThemeProvider
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, auth, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'BankingApp',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.mode, // Controlled by ThemeProvider
            home: auth.isAuthenticated ? const HomeShell() : const LoginScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/deposit': (context) => const DepositScreen(),
              '/withdraw': (context) => const WithdrawScreen(),
              '/transfer': (context) => const TransferScreen(),
              '/history': (context) => const HistoryScreen(),
            },
            // Optional builder to lock textScaleFactor or apply global adjustments
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
