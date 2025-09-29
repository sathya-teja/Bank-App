import 'package:flutter/material.dart';
import '../../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _svc = ProfileService();
  final _formKey = GlobalKey<FormState>();

  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _aadhar = TextEditingController();
  final _pan = TextEditingController();
  DateTime? _dob;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _svc.myProfile();
    if (p != null) {
      _fullName.text = p['fullName'] ?? '';
      _phone.text = p['phone'] ?? '';
      _aadhar.text = p['aadhar'] ?? '';
      _pan.text = p['pan'] ?? '';
      if (p['dob'] != null) {
        _dob = DateTime.tryParse(p['dob']);
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final res = await _svc.upsertProfile({
      'fullName': _fullName.text.trim(),
      'phone': _phone.text.trim(),
      'dob': _dob?.toIso8601String(),
      'aadhar': _aadhar.text.trim(),
      'pan': _pan.text.trim(),
    });

    if (!mounted) return;
    setState(() => _saving = false);

    final success = res['status'] == 200 || res['status'] == 201;

    // ✅ Show custom popup in center
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop(); // close dialog
          Navigator.pop(context, true); // go back to profile screen
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
                      ? "Profile updated successfully"
                      : "Failed to update profile",
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

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile"), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _fullName,
                      decoration: _dec("Full Name", Icons.person),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: _dec("Phone", Icons.phone),
                      validator: (v) =>
                          v != null && v.trim().length == 10
                              ? null
                              : "Enter valid 10-digit phone",
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: _pickDob,
                      child: InputDecorator(
                        decoration: _dec("Date of Birth", Icons.cake),
                        child: Text(
                          _dob != null
                              ? "${_dob!.day}/${_dob!.month}/${_dob!.year}"
                              : "Select Date",
                          style: TextStyle(
                            color: _dob != null
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _aadhar,
                      keyboardType: TextInputType.number,
                      decoration: _dec("Aadhar", Icons.badge),
                      validator: (v) =>
                          v != null && v.trim().length == 12
                              ? null
                              : "Enter valid 12-digit Aadhar",
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _pan,
                      textCapitalization: TextCapitalization.characters,
                      decoration: _dec("PAN", Icons.credit_card),
                      validator: (v) =>
                          v != null && v.trim().length == 10
                              ? null
                              : "Enter valid PAN",
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
