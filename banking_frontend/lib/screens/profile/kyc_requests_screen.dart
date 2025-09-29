import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:banking_frontend/providers/auth_provider.dart';
import 'package:banking_frontend/services/api_client.dart';

class KycRequestsScreen extends StatefulWidget {
  const KycRequestsScreen({super.key});

  @override
  State<KycRequestsScreen> createState() => _KycRequestsScreenState();
}

class _KycRequestsScreenState extends State<KycRequestsScreen> {
  final _api = ApiClient();
  List<Map<String, dynamic>> _pendingProfiles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingProfiles();
  }

 Future<void> _fetchPendingProfiles() async {
  setState(() => _loading = true);
  try {
    final res = await _api.get('/profiles/pending');
    debugPrint("Response status: ${res.statusCode}");
    debugPrint("Response body: ${res.body}");

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);

      final profiles = decoded is Map<String, dynamic>
          ? (decoded['profiles'] ?? [])
          : decoded;

      setState(() {
        _pendingProfiles = List<Map<String, dynamic>>.from(profiles);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profiles (${res.statusCode})")),
      );
    }
  } catch (e) {
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

  Future<void> _updateProfile(String id, String status) async {
    try {
      final res = await _api.patch('/profiles/$id/kyc', {
        'kycStatus': status, // backend expects this key
      });

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile marked as $status")),
        );
        _fetchPendingProfiles();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile (${res.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (!auth.isAdmin) {
      return const Scaffold(
        body: Center(child: Text("Access Denied: Admins only")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Pending KYC Requests")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pendingProfiles.isEmpty
              ? const Center(child: Text("No pending KYC requests"))
              : ListView.builder(
                  itemCount: _pendingProfiles.length,
                  itemBuilder: (ctx, i) {
                    final p = _pendingProfiles[i];

                    final fullName = p['fullName'] ?? p['name'] ?? "No Name";
                    final email = p['email'] ?? '';
                    final aadhar = p['aadhar'] ?? p['aadhaarNumber'] ?? '';
                    final pan = p['pan'] ?? p['panNumber'] ?? '';

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(fullName),
                        subtitle: Text(
                          "Email: $email\nAadhar: $aadhar\nPAN: $pan",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              tooltip: "Approve",
                              onPressed: () =>
                                  _updateProfile(p['_id'] as String, 'verified'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              tooltip: "Reject",
                              onPressed: () =>
                                  _updateProfile(p['_id'] as String, 'rejected'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
