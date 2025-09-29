import 'dart:convert';
import 'api_client.dart';

class AccountService {
  final _api = ApiClient();

  Future<List<dynamic>> myAccounts() async {
    final res = await _api.get('/accounts');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['accounts'] ?? [];
    }
    return [];
  }

  Future<Map<String, dynamic>> createAccount({String type = 'SAV'}) async {
    final res = await _api.post('/accounts', {'type': type});
    return {'status': res.statusCode, 'data': jsonDecode(res.body)};
  }
}
