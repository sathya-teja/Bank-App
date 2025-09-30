import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _svc = ProfileService();
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _svc.myProfile();
    if (p != null) {
      setState(() => _profile = p);
    }
    setState(() => _loading = false);
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 6, bottom: 6),
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
              ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green.shade100,
        child: Icon(icon, color: Colors.green.shade700),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(value.isNotEmpty ? value : 'Not added',
          style: const TextStyle(color: Colors.black87)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1B998B), Color(0xFF046865)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 🔹 Avatar with photoUrl fallback
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 46,
                                backgroundColor: Colors.white,
                                backgroundImage: _profile?['photoUrl'] != null &&
                                        (_profile?['photoUrl'] as String).isNotEmpty
                                    ? NetworkImage(_profile!['photoUrl'])
                                    : null,
                                child: (_profile?['photoUrl'] == null ||
                                        (_profile?['photoUrl'] as String).isEmpty)
                                    ? Text(
                                        (_profile?['fullName'] ??
                                                auth.user?['fullName'] ??
                                                'U')[0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Full name
                            Text(
                              _profile?['fullName'] ??
                                  auth.user?['fullName'] ??
                                  'User',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            // Phone
                            Text(
                              _profile?['phone'] ?? auth.user?['phone'] ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white70,
                              ),
                            ),
                            // ✅ KYC badge
                            if ((_profile?['kycStatus'] ?? '') == 'verified')
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade600,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.verified,
                                        color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text("KYC Completed",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              )
                            else if ((_profile?['kycStatus'] ?? '') ==
                                'pending')
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade600,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.hourglass_bottom,
                                        color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text("KYC Pending",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),
                            // Edit profile button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.teal,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () async {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfileScreen(),
                                  ),
                                );
                                if (updated == true) {
                                  _load();
                                }
                              },
                              child: const Text("Edit Profile"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 🔹 Info Sections
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Personal Info
                        _sectionCard("Personal Info", [
                          _infoTile(Icons.email, "Email",
                              _profile?['email'] ?? auth.user?['email'] ?? ''),
                          const Divider(),
                          _infoTile(Icons.badge, "Aadhar",
                              _profile?['aadhar'] ?? ''),
                          const Divider(),
                          _infoTile(Icons.credit_card, "PAN",
                              _profile?['pan'] ?? ''),
                          const Divider(),
                          _infoTile(Icons.cake, "Date of Birth",
                              _profile?['dob'] ?? ''),
                        ]),

                        // 🔹 Address
                        _sectionCard("Address", [
                          _infoTile(Icons.home, "Line 1",
                              _profile?['address']?['line1'] ?? ''),
                          const Divider(),
                          _infoTile(Icons.home_work, "Line 2",
                              _profile?['address']?['line2'] ?? ''),
                          const Divider(),
                          _infoTile(Icons.location_city, "City",
                              _profile?['address']?['city'] ?? ''),
                          const Divider(),
                          _infoTile(Icons.map, "State",
                              _profile?['address']?['state'] ?? ''),
                          const Divider(),
                          _infoTile(Icons.local_post_office, "Postal Code",
                              _profile?['address']?['postalCode'] ?? ''),
                        ]),

                        // Security
                        _sectionCard("Security", [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.shade100,
                              child: Icon(Icons.lock,
                                  color: Colors.orange.shade700),
                            ),
                            title: const Text("Change Password"),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ChangePasswordScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.shade100,
                              child: Icon(Icons.logout,
                                  color: Colors.red.shade700),
                            ),
                            title: const Text("Logout"),
                            onTap: () {
                              context.read<AuthProvider>().logout();
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                            },
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
