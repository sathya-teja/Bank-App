import 'package:flutter/material.dart';
import '../../services/transaction_service.dart';
import '../../widgets/tx_list_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _txSvc = TransactionService();
  bool _loading = true;
  List<dynamic> _transactions = [];
  String _filter = "all"; // filter state

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final txs = await _txSvc.recentTransactions(limit: 50);
      setState(() {
        _transactions = txs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _transactions = [];
        _loading = false;
      });
    }
  }

  List<dynamic> get _filteredTx {
    if (_filter == "all") return _transactions;
    return _transactions.where((tx) {
      final type = (tx['type'] ?? '').toString().toLowerCase();
      return type == _filter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔹 Filter Bar with soft fills
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text("All"),
                  selected: _filter == "all",
                  selectedColor: Colors.grey.shade200,
                  onSelected: (_) => setState(() => _filter = "all"),
                ),
                ChoiceChip(
                  label: const Text("Credits"),
                  selected: _filter == "credit",
                  selectedColor: Colors.green.shade100,
                  onSelected: (_) => setState(() => _filter = "credit"),
                ),
                ChoiceChip(
                  label: const Text("Debits"),
                  selected: _filter == "debit",
                  selectedColor: Colors.red.shade100,
                  onSelected: (_) => setState(() => _filter = "debit"),
                ),
              ],
            ),
          ),

          // 🔹 Transactions List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTx.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.receipt_long,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              "No transactions found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredTx.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final tx = _filteredTx[i];
                            final type =
                                (tx['type'] ?? '').toString().toLowerCase();
                            final isCredit = type == "credit";

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: TxListTile(
                                  tx: tx,
                                  highlightColor:
                                      isCredit ? Colors.green : Colors.red,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
