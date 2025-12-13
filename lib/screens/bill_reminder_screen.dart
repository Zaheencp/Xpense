import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bill_model.dart';
import '../controllers/bill_provider.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import '../services/calendar_service.dart';

class BillReminderScreen extends StatefulWidget {
  const BillReminderScreen({super.key});

  @override
  State<BillReminderScreen> createState() => _BillReminderScreenState();
}

class _BillReminderScreenState extends State<BillReminderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BillProvider>(context, listen: false).listenToBills();
    });
  }

  void _showBillDetails(BuildContext context, BillModel bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bill Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow('Bill Name', bill.name),
            _buildDetailRow('Amount', '\$${bill.amount.toStringAsFixed(2)}'),
            _buildDetailRow(
                'Due Date', DateFormat('MMM dd, yyyy').format(bill.dueDate)),
            _buildDetailRow('Status', bill.isPaid ? 'Paid' : 'Unpaid'),
            if (bill.recurrence != null)
              _buildDetailRow('Recurrence', bill.recurrence!),
            if (bill.reminderDays != null)
              _buildDetailRow(
                  'Reminder', '${bill.reminderDays} days before due date'),
            if (bill.notes != null && bill.notes!.isNotEmpty)
              _buildDetailRow('Notes', bill.notes!),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBillDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final reminderDaysController = TextEditingController(text: '1');
    DateTime? dueDate;
    String? selectedRecurrence;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Add Bill Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Bill Name'),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: notesController,
                  decoration:
                      const InputDecoration(labelText: 'Notes (optional)'),
                ),
                DropdownButtonFormField<String>(
                  // initialValue: selectedRecurrence,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('None')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                  ],
                  onChanged: (val) =>
                      setStateDialog(() => selectedRecurrence = val),
                  decoration: const InputDecoration(labelText: 'Recurrence'),
                ),
                TextField(
                  controller: reminderDaysController,
                  decoration: const InputDecoration(
                      labelText: 'Remind me X days before'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(dueDate == null
                        ? 'No due date'
                        : 'Due: \n${dueDate!.toLocal().toString().split(' ')[0]}'),
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
                            dueDate = picked;
                          });
                        }
                      },
                      child: const Text('Pick Due Date'),
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
                    amountController.text.isEmpty ||
                    dueDate == null) {
                  return;
                }
                final bill = BillModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  amount: double.tryParse(amountController.text) ?? 0,
                  dueDate: dueDate!,
                  isPaid: false,
                  notes: notesController.text,
                  recurrence: selectedRecurrence,
                  reminderDays: int.tryParse(reminderDaysController.text) ?? 1,
                );
                final error =
                    await Provider.of<BillProvider>(context, listen: false)
                        .addBill(bill);
                if (!context.mounted) return;

                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error)),
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bill added successfully')),
                  );
                }
              },
              child: const Text('Add Bill'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSnoozeDialog(
      BuildContext context, BillModel bill, int notificationId) {
    int hours = 0;
    int minutes = 10;
    return AlertDialog(
      title: const Text('Custom Snooze'),
      content: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(labelText: 'Hours'),
              keyboardType: TextInputType.number,
              onChanged: (val) => hours = int.tryParse(val) ?? 0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(labelText: 'Minutes'),
              keyboardType: TextInputType.number,
              onChanged: (val) => minutes = int.tryParse(val) ?? 0,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final duration = Duration(hours: hours, minutes: minutes);
            await NotificationService.snoozeNotification(
              id: notificationId,
              title: 'Upcoming Bill: ${bill.name}',
              body:
                  'Amount: \$${bill.amount} due on ${bill.dueDate.toLocal().toString().split(' ')[0]}',
              snoozeDuration: duration,
            );
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Reminder snoozed for ${hours}h ${minutes}m')));
          },
          child: const Text('Snooze'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bills = Provider.of<BillProvider>(context).bills;
    final now = DateTime.now();
    final upcomingBills = bills
        .where((b) =>
            !b.isPaid &&
            b.dueDate.isAfter(now.subtract(const Duration(days: 1))))
        .toList();
    final paidBills = bills.where((b) => b.isPaid).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Bill Reminders')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBillDialog(context),
        tooltip: 'Add Bill Reminder',
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Upcoming Bills',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          ...upcomingBills.map((bill) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(bill.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Due: \n${DateFormat('yyyy-MM-dd').format(bill.dueDate)}'),
                      if (bill.recurrence != null &&
                          bill.recurrence!.isNotEmpty)
                        Text(
                            'Recurs: \n${bill.recurrence![0].toUpperCase()}${bill.recurrence!.substring(1)}',
                            style: const TextStyle(color: Colors.blueGrey)),
                      if (bill.notes != null && bill.notes!.isNotEmpty)
                        Text('Notes: \n${bill.notes}'),
                    ],
                  ),
                  leading: bill.calendarEventId != null
                      ? const Tooltip(
                          message: 'Added to Calendar',
                          child: Icon(Icons.calendar_today, color: Colors.blue))
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('\n${bill.amount.toStringAsFixed(2)}'),
                      if (bill.calendarEventId != null)
                        IconButton(
                          icon: const Icon(Icons.event_busy,
                              color: Colors.redAccent),
                          tooltip: 'Remove from Calendar',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Remove from Calendar'),
                                content: const Text(
                                    'Are you sure you want to remove this bill from your calendar?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel')),
                                  ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Remove')),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              final removed =
                                  await CalendarService.removeBillFromCalendar(
                                      bill.calendarEventId!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(removed
                                        ? 'Removed from calendar'
                                        : 'Failed to remove from calendar')),
                              );
                            }
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.snooze, color: Colors.orange),
                        tooltip: 'Snooze Reminder',
                        onPressed: () {
                          final notificationId = ('${bill.id}_0').hashCode;
                          showDialog(
                            context: context,
                            builder: (context) => _buildCustomSnoozeDialog(
                                context, bill, notificationId),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: 'Cancel Reminder',
                        onPressed: () async {
                          final notificationId = ('${bill.id}_0').hashCode;
                          await NotificationService.cancelNotification(
                              notificationId);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Reminder cancelled')));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        tooltip: 'Mark as Paid',
                        onPressed: () async {
                          final error = await Provider.of<BillProvider>(context,
                                  listen: false)
                              .markBillPaid(bill.id);
                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error)),
                            );
                          } else {
                            final notificationId = ('${bill.id}_0').hashCode;
                            await NotificationService.cancelNotification(
                                notificationId);
                          }
                        },
                      ),
                    ],
                  ),
                  isThreeLine: bill.notes != null && bill.notes!.isNotEmpty,
                  subtitleTextStyle: TextStyle(color: Colors.grey[700]),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  onTap: () {},
                ),
              )),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Paid Bills',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          ...paidBills.map((bill) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(bill.name),
                  subtitle: Text(
                      'Paid: \n${DateFormat('yyyy-MM-dd').format(bill.dueDate)}'),
                  trailing: Text('\n${bill.amount.toStringAsFixed(2)}'),
                  isThreeLine: bill.notes != null && bill.notes!.isNotEmpty,
                  subtitleTextStyle: TextStyle(color: Colors.grey[700]),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  onTap: () {},
                ),
              )),
        ],
      ),
    );
  }
}
