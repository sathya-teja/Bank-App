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
      'accountNumber': accountNumber,
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
      'accountNumber': accountNumber,
      'amount': amount,
      if (description != null) 'description': description,
    });

    final decoded = _safeDecode(res.body);

    if (res.statusCode == 201 &&
        decoded is Map &&
        decoded['ok'] == true &&
        decoded['transaction'] != null) {
      final tx = decoded['transaction'];
      final normalizedAmount =
          (tx['amount'] is num) ? tx['amount'] / 100 : tx['amount'];
      return {
        'status': res.statusCode,
        'transaction': {
          ...tx,
          'amount': normalizedAmount,
        },
      };
    }

    return {
      'status': res.statusCode,
      'error': decoded['error'] ?? 'Withdrawal failed',
    };
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
      'fromAccountNumber': fromAccountNumber,
      'toAccountNumber': toAccountNumber,
      'amount': amount,
      if (description != null) 'description': description,
      if (refId != null) 'refId': refId,
    });

    final decoded = _safeDecode(res.body);

    if (res.statusCode == 201 &&
        decoded is Map &&
        decoded['debitTransaction'] != null) {
      final tx = decoded['debitTransaction'];
      final normalizedAmount =
          (tx['amount'] is num) ? tx['amount'] / 100 : tx['amount'];
      return {
        'status': res.statusCode,
        'transaction': {
          ...tx,
          'amount': normalizedAmount,
        },
      };
    }

    return {'status': res.statusCode, 'data': decoded};
  }

  /// Recent transactions
  Future<List<dynamic>> recentTransactions({int limit = 5}) async {
    try {
      final res = await _api.get('/tx/my');
      final data = _safeDecode(res.body);

      if (res.statusCode == 200 && data is List) {
        return data.take(limit).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching recent transactions: $e');
      return [];
    }
  }

  /// Pay a bill
  Future<Map<String, dynamic>> payBill({
    required String accountNumber,
    required double amount,
    required String billType,
    String? description,
    String? refId,
  }) async {
    final res = await _api.post('/tx/bill', {
      'accountNumber': accountNumber,
      'amount': amount,
      'billType': billType,
      if (description != null) 'description': description,
      if (refId != null) 'refId': refId,
    });

    final decoded = _safeDecode(res.body);

    if (res.statusCode == 201 &&
        decoded is Map &&
        decoded['ok'] == true &&
        decoded['transaction'] != null) {
      final tx = decoded['transaction'];
      final normalizedAmount =
          (tx['amount'] is num) ? tx['amount'] / 100 : tx['amount'];
      return {
        'status': res.statusCode,
        'transaction': {
          ...tx,
          'amount': normalizedAmount,
        },
      };
    }

    return {
      'status': res.statusCode,
      'error': decoded['error'] ?? 'Bill payment failed',
    };
  }

  dynamic _safeDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}
