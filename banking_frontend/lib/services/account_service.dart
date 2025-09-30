import 'dart:convert';
import 'api_client.dart';

class AccountService {
  final _api = ApiClient();

  /// 🔹 Helper to safely decode JSON responses
  Map<String, dynamic> _safeDecodeResponse(dynamic res) {
    try {
      final data = res.body.isNotEmpty ? jsonDecode(res.body) : {};
      return {
        'status': res.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'status': res.statusCode,
        'data': {'error': res.body}, // fallback with raw body
      };
    }
  }

  /// 🔹 Get all accounts of the logged-in user
  Future<List<dynamic>> myAccounts() async {
    final res = await _api.get('/accounts');
    if (res.statusCode == 200 && res.body.isNotEmpty) {
      try {
        final data = jsonDecode(res.body);
        return data['accounts'] ?? [];
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  /// 🔹 Create a new account (default type = SAV)
  Future<Map<String, dynamic>> createAccount({String type = 'SAV'}) async {
    final res = await _api.post('/accounts', {'type': type});
    return _safeDecodeResponse(res);
  }

  /// 🔹 Create a new savings goal for an account
  Future<Map<String, dynamic>> createGoal({
    required String accountNumber,
    required String title,         // ✅ use "title" instead of "name"
    required double targetAmount,
  }) async {
    final res = await _api.post('/accounts/goal', {
      'accountNumber': accountNumber,
      'title': title,              // ✅ backend expects "title"
      'targetAmount': targetAmount,
    });
    return _safeDecodeResponse(res);
  }

  /// 🔹 Contribute to an existing savings goal
  Future<Map<String, dynamic>> contributeGoal({
    required String accountNumber,
    required String goalId,
    required double amount,
  }) async {
    final res = await _api.post('/accounts/goal/contribute', {
      'accountNumber': accountNumber,
      'goalId': goalId,
      'amount': amount,
    });
    return _safeDecodeResponse(res);
  }

  /// 🔹 Get all savings goals for a specific account
  Future<List<dynamic>> getGoals(String accountNumber) async {
    final res = await _api.get('/accounts/$accountNumber/goals');
    if (res.statusCode == 200 && res.body.isNotEmpty) {
      try {
        final data = jsonDecode(res.body);

        // ✅ Case 1: backend returns a raw array
        if (data is List) {
          return data;
        }

        // ✅ Case 2: backend wraps goals inside an object
        if (data is Map && data['goals'] != null) {
          return data['goals'];
        }
      } catch (_) {
        return [];
      }
    }
    return [];
  }
}
