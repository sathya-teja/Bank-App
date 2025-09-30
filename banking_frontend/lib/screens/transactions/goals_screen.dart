import 'package:flutter/material.dart';
import '../../services/account_service.dart';

class GoalsScreen extends StatefulWidget {
  final String accountNumber;
  const GoalsScreen({super.key, required this.accountNumber});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _accountService = AccountService();
  List<dynamic> _goals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() => _loading = true);
    final goals = await _accountService.getGoals(widget.accountNumber);
    setState(() {
      _goals = goals;
      _loading = false;
    });
  }

  Future<void> _createGoal() async {
    final controllerTitle = TextEditingController();
    final controllerTarget = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Create New Goal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controllerTitle,
              decoration: const InputDecoration(
                labelText: "Goal Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controllerTarget,
              decoration: const InputDecoration(
                labelText: "Target Amount (₹)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = controllerTitle.text.trim();
              final target = double.tryParse(controllerTarget.text.trim());

              if (title.isEmpty || target == null || target <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter valid goal details ❗")),
                );
                return;
              }

              final result = await _accountService.createGoal(
                accountNumber: widget.accountNumber,
                title: title,
                targetAmount: target,
              );

              Navigator.pop(context);

              final status = result['status'];
              if (status == 200 || status == 201) {
                await _loadGoals(); // ✅ refresh after creation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Goal created successfully ✅")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to create goal ❌ ${result['data']}")),
                );
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  Future<void> _contributeGoal(String goalId) async {
    final controllerAmount = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Contribute to Goal"),
        content: TextField(
          controller: controllerAmount,
          decoration: const InputDecoration(
            labelText: "Amount (₹)",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controllerAmount.text.trim());
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter valid amount ❗")),
                );
                return;
              }

              final result = await _accountService.contributeGoal(
                accountNumber: widget.accountNumber,
                goalId: goalId,
                amount: amount,
              );

              Navigator.pop(context);
              final status = result['status'];
              if (status == 200 || status == 201) {
                await _loadGoals(); // ✅ refresh after contribution
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Contribution added ✅")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Contribution failed ❌ ${result['data']}")),
                );
              }
            },
            child: const Text("Contribute"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Savings Goals")),
      body: _goals.isEmpty
          ? const Center(child: Text("No goals yet. Tap + to create one!"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _goals.length,
              itemBuilder: (_, i) {
                final g = _goals[i];
                // ✅ Convert from paise → rupees
                final saved = ((g['savedAmount'] ?? 0) / 100).toDouble();
                final target = ((g['targetAmount'] ?? 1) / 100).toDouble();
                final progress = (target > 0) ? (saved / target).clamp(0.0, 1.0) : 0.0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      g['title'] ?? 'Untitled Goal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green,
                          backgroundColor: Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        Text("₹${saved.toStringAsFixed(2)} / ₹${target.toStringAsFixed(2)}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue),
                      onPressed: () => _contributeGoal(g['_id'].toString()), // ✅ use _id
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGoal,
        backgroundColor: const Color(0xFF1B998B),
        child: const Icon(Icons.add),
      ),
    );
  }
}
