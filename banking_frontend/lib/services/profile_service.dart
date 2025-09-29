import 'dart:convert';
import 'api_client.dart';

class ProfileService {
  final _api = ApiClient();

  Future<Map<String, dynamic>?> myProfile() async {
    final res = await _api.get('/profile/me');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['profile'];
    }
    return null;
  }

  Future<Map<String, dynamic>> upsertProfile(Map<String, dynamic> body) async {
    final res = await _api.post('/profile', body);
    return {'status': res.statusCode, 'data': jsonDecode(res.body)};
  }

  /// 🔹 New: Change Password
  Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword) async {
    final res = await _api.post('/auth/change-password', {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });

    return {
      'status': res.statusCode,
      'data': jsonDecode(res.body),
    };
  }
}
