import 'dart:convert';
import 'api_client.dart';

class AuthService {
  final _api = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _api.post(
      '/auth/login',
      {'email': email, 'password': password},
    );

    return {
      'status': res.statusCode,
      'data': jsonDecode(res.body),
    };
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password, {
    String? inviteCode,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
    };

    if (inviteCode != null) body['inviteCode'] = inviteCode;

    final res = await _api.post('/auth/register', body);

    // normalize status: if backend sends 201, treat as 200
    final status = (res.statusCode == 201) ? 200 : res.statusCode;

    return {
      'status': status,
      'data': jsonDecode(res.body),
    };
  }
}
