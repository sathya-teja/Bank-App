import 'package:flutter/material.dart';

class ReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> tx;

  const ReceiptScreen({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final hasError = tx.containsKey('error');
    // ✅ Detect if it's a valid transaction object
    final success = !hasError &&
        (tx['ok'] == true ||
            tx['status'] == 200 ||
            tx['status'] == 201 ||
            tx['_id'] != null); // 👈 also success if ID exists

    final amount = _toCurrency(tx['amount']);
    final fromAcc = tx['fromAccount'] ?? tx['fromAccountNumber'] ?? '-';
    final toAcc = tx['toAccount'] ?? tx['toAccountNumber']; // 👈 only show if exists
    final desc = tx['description'] ?? '-';
    final txId = tx['_id'] ?? tx['transactionId'] ?? 'N/A';
    final date = tx['createdAt'] != null
        ? DateTime.tryParse(tx['createdAt'].toString())
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Receipt"),
        centerTitle: true,
        backgroundColor: Colors.green.shade600,
      ),
      body: SingleChildScrollView( // ✅ scrollable
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
              size: 80,
            ),
            const SizedBox(height: 12),
            Text(
              hasError
                  ? "Transaction Failed"
                  : (success ? "Payment Successful" : "Payment Failed"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: success ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 24),

            if (hasError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  tx['error'].toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            if (!hasError) ...[
              _buildRow("Transaction ID", txId.toString()),
              _buildRow("From Account", fromAcc.toString()),

              // 👇 Only show To Account if it exists (transfer/bill)
              if (toAcc != null && toAcc.toString().isNotEmpty)
                _buildRow("To Account", toAcc.toString()),

              _buildRow("Amount", amount),
              _buildRow("Description", desc.toString()),
              _buildRow(
                "Date & Time",
                date != null
                    ? "${date.day}-${date.month}-${date.year} "
                        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}"
                    : "N/A",
              ),
            ],

            const SizedBox(height: 30), // ✅ replaces Spacer
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home),
              label: const Text(
                "Back to Home",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _toCurrency(dynamic value) {
    if (value == null) return "₹ 0.00";
    try {
      final doubleVal =
          value is num ? value.toDouble() : double.parse(value.toString());
      return "₹ ${doubleVal.toStringAsFixed(2)}";
    } catch (_) {
      return "₹ 0.00";
    }
  }

  Widget _buildRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
