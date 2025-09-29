import 'dart:convert';
import 'api_client.dart';
import '../core/utils/config.dart';

class TransactionService {
  final _api = ApiClient();

  /// Deposit (admin only)
  Future<Map<String, dynamic>> deposit(
    String accountNumber,
    double amount, {
    String? description,
    String? refId,
  }) async {
    final res = await _api.post('/tx/deposit', {
      'accountNumber': accountNumber,   // ✅ use accountNumber, not accountId
      'amount': amount,
      if (description != null) 'description': description,
      if (refId != null) 'refId': refId,
    });
    return {'status': res.statusCode, 'data': _safeDecode(res.body)};
  }

  /// Withdraw (customer only, or admin override)
  Future<Map<String, dynamic>> withdraw(
    String accountNumber,
    double amount, {
    String? description,
  }) async {
    final res = await _api.post('/tx/withdraw', {
      'accountNumber': accountNumber,   // ✅ updated
      'amount': amount,
      if (description != null) 'description': description,
    });
    return {'status': res.statusCode, 'data': _safeDecode(res.body)};
  }

  /// Transfer (between accounts)
  Future<Map<String, dynamic>> transfer(
    String fromAccountNumber,
    String toAccountNumber,
    double amount, {
    String? description,
    String? refId,
  }) async {
    final res = await _api.post('/tx/transfer', {
      'fromAccountNumber': fromAccountNumber,   // ✅ updated
      'toAccountNumber': toAccountNumber,       // ✅ consistent with backend
      'amount': amount,
      if (description != null) 'description': description,
      if (refId != null) 'refId': refId,
    });
    return {'status': res.statusCode, 'data': _safeDecode(res.body)};
  }

  /// Recent transactions for the logged-in user
  Future<List<dynamic>> recentTransactions({int limit = 5}) async {
    try {
      final res = await _api.get('/tx/my');
      final data = _safeDecode(res.body);

      if (res.statusCode == 200 && data is List) {
        // return only the latest "limit" items
        return data.take(limit).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching recent transactions: $e');
      return [];
    }
  }

  dynamic _safeDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}
