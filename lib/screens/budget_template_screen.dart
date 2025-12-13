import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal_model.dart';
import '../controllers/goal_provider.dart';

class BudgetTemplateScreen extends StatefulWidget {
  const BudgetTemplateScreen({super.key});

  @override
  State<BudgetTemplateScreen> createState() => _BudgetTemplateScreenState();
}

class _BudgetTemplateScreenState extends State<BudgetTemplateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GoalProvider>(context, listen: false).listenToGoals();
    });
  }

  void _showAddGoalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Set Financial Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Goal Name'),
                ),
                TextField(
                  controller: targetController,
                  decoration: const InputDecoration(labelText: 'Target Amount'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: notesController,
                  decoration:
                      const InputDecoration(labelText: 'Notes (optional)'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(selectedDate == null
                        ? 'No deadline'
                        : 'Deadline: \n${selectedDate!.toLocal().toString().split(' ')[0]}'),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateDialog(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: const Text('Pick Deadline'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    targetController.text.isEmpty) {
                  return;
                }
                final goal = GoalModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  targetAmount: double.tryParse(targetController.text) ?? 0,
                  currentAmount: 0,
                  deadline: selectedDate,
                  notes: notesController.text,
                );
                final error = await Provider.of<GoalProvider>(context, listen: false)
                    .addGoal(goal);
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error)),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(String title, String description) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgress(BuildContext context, GoalModel goal) {
    final percent = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: percent),
            const SizedBox(height: 8),
            Text('Saved: \n${goal.currentAmount} / \n${goal.targetAmount}'),
            if (goal.deadline != null)
              Text(
                  'Deadline: \n${goal.deadline!.toLocal().toString().split(' ')[0]}'),
            if (goal.notes != null && goal.notes!.isNotEmpty)
              Text('Notes: \n${goal.notes}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _showAddProgressDialog(context, goal);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProgressDialog(BuildContext context, GoalModel goal) {
    final progressController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Progress to Goal'),
        content: TextField(
          controller: progressController,
          decoration: const InputDecoration(labelText: 'Amount to add'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final addAmount = double.tryParse(progressController.text) ?? 0;
              final updatedGoal = GoalModel(
                id: goal.id,
                name: goal.name,
                targetAmount: goal.targetAmount,
                currentAmount: (goal.currentAmount + addAmount)
                    .clamp(0, goal.targetAmount),
                deadline: goal.deadline,
                notes: goal.notes,
              );
              final error = await Provider.of<GoalProvider>(context, listen: false)
                  .updateGoal(updatedGoal);
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error)),
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = Provider.of<GoalProvider>(context).goals;
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Templates & Goals')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        tooltip: 'Add Financial Goal',
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildTemplateCard('50/30/20 Rule',
              'Allocate 50% to needs, 30% to wants, 20% to savings.'),
          _buildTemplateCard('Zero-Based Budget',
              'Assign every dollar a job. Income - Expenses = 0.'),
          _buildTemplateCard('Envelope System',
              'Use envelopes for each spending category to control cash flow.'),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Your Financial Goals',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          ...goals.map((goal) => _buildGoalProgress(context, goal)),
        ],
      ),
    );
  }
}
