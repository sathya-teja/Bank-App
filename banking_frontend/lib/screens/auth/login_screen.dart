import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../home/home_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(); // only for register
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _inviteCode = TextEditingController(); // optional admin register
  bool _loading = false;
  bool _isLogin = true; // toggle between login & register
  final _authSvc = AuthService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🔹 Branding / Logo
                    const FlutterLogo(size: 80),
                    const SizedBox(height: 16),
                    Text(
                      "BankingApp",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      _isLogin
                          ? "Securely sign in to your account"
                          : "Create your new account",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 🔹 Name (Register only)
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        validator: (v) =>
                            Validators.notEmpty(v, field: 'Name'),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 🔹 Email
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Password
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (v) =>
                          Validators.minLen(v, 6, field: 'Password'),
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Invite code (Register only)
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _inviteCode,
                        decoration: const InputDecoration(
                          labelText: 'Invite Code (admin only)',
                          prefixIcon: Icon(Icons.vpn_key_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 8),

                    // 🔹 Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _loading
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;
                                setState(() => _loading = true);

                                Map<String, dynamic> res;
                                if (_isLogin) {
                                  res = await _authSvc.login(
                                    _email.text.trim(),
                                    _password.text.trim(),
                                  );
                                } else {
                                  res = await _authSvc.register(
                                    _name.text.trim(),
                                    _email.text.trim(),
                                    _password.text.trim(),
                                    inviteCode: _inviteCode.text.trim().isEmpty
                                        ? null
                                        : _inviteCode.text.trim(),
                                  );
                                }

                                setState(() => _loading = false);
                                if (!mounted) return;

                                if (res['status'] == 200 &&
                                    res['data']['ok'] == true) {
                                  final token = res['data']['token'] as String;
                                  final user = res['data']['user']
                                      as Map<String, dynamic>;
                                  await context
                                      .read<AuthProvider>()
                                      .saveSession(token, user);
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (_) => const HomeShell()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${_isLogin ? "Login" : "Register"} failed: ${res['data']}',
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                _isLogin ? 'Sign in' : 'Register',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🔹 Toggle Login/Register
                    TextButton(
                      onPressed: () {
                        setState(() => _isLogin = !_isLogin);
                      },
                      child: Text(
                        _isLogin
                            ? "Don't have an account? Register"
                            : "Already have an account? Sign in",
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
