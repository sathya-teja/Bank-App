import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TxListTile extends StatelessWidget {
  final Map<String, dynamic> tx;
  /// Optional accent color (used for icon + amount). If not provided,
  /// it uses green for credits and red for debits.
  final Color? highlightColor;

  const TxListTile({
    super.key,
    required this.tx,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final type = (tx['type'] ?? '').toString().toLowerCase();
    final isCredit = type == 'credit';

    final Color accent =
        highlightColor ?? (isCredit ? Colors.green : Colors.red);

    final num amountRupees = (tx['amount'] ?? 0) as num;         // already in ₹
    final num balanceRupees = (tx['balanceAfter'] ?? 0) as num;  // already in ₹

    String createdAt = '';
    final rawDate = tx['createdAt'];
    if (rawDate != null) {
      final parsed = DateTime.tryParse(rawDate.toString());
      if (parsed != null) {
        createdAt = DateFormat('dd MMM yyyy, hh:mm a').format(parsed.toLocal());
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: accent.withOpacity(0.12),
        child: Icon(
          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
          color: accent,
          size: 22,
        ),
      ),
      title: Text(
        (tx['description']?.toString().isNotEmpty ?? false)
            ? tx['description'].toString()
            : type.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        createdAt.isNotEmpty ? createdAt : 'No date',
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            (isCredit ? '+ ' : '- ') + '₹${amountRupees.toStringAsFixed(2)}',
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bal: ₹${balanceRupees.toStringAsFixed(2)}',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
