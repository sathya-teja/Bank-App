import 'package:flutter/material.dart';
import '../../services/profile_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _svc = ProfileService();
  final _formKey = GlobalKey<FormState>();

  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();

  bool _saving = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final res = await _svc.changePassword(
      _oldPass.text.trim(),
      _newPass.text.trim(),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    final success = res['status'] == 'success' || res['status'] == 200;

    // ✅ Show custom popup in center
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop(); // close dialog
          if (success) Navigator.pop(context, true); // back to profile only if success
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Icon(
                    success ? Icons.check_circle : Icons.error,
                    color: success ? Colors.green : Colors.red,
                    size: 70,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  success
                      ? "Password changed successfully"
                      : "Failed to change password",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _dec(String label, IconData icon, bool obscure, VoidCallback toggle) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
        onPressed: toggle,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _oldPass,
                obscureText: _obscureOld,
                decoration: _dec("Old Password", Icons.lock, _obscureOld, () {
                  setState(() => _obscureOld = !_obscureOld);
                }),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter old password" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _newPass,
                obscureText: _obscureNew,
                decoration: _dec("New Password", Icons.lock_outline, _obscureNew, () {
                  setState(() => _obscureNew = !_obscureNew);
                }),
                validator: (v) =>
                    v == null || v.length < 6 ? "At least 6 characters" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmPass,
                obscureText: _obscureConfirm,
                decoration: _dec("Confirm Password", Icons.lock_reset, _obscureConfirm, () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                }),
                validator: (v) =>
                    v != _newPass.text ? "Passwords do not match" : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Save Changes",
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
