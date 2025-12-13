import 'package:flutter/material.dart';
import '../models/bill_model.dart';
import '../services/bill_service.dart';
import '../services/notification_service.dart';

class BillProvider extends ChangeNotifier {
  final BillService _billService = BillService();
  List<BillModel> _bills = [];

  List<BillModel> get bills => _bills;

  void listenToBills() {
    _billService.fetchBills().listen((billList) {
      _bills = billList;
      notifyListeners();
    });
  }

  Future<String?> addBill(BillModel bill) async {
    final error = await _billService.addBill(bill);
    if (error != null) {
      return error;
    }
    DateTime nextDue = bill.dueDate;
    for (int i = 0; i < 12; i++) {
      // schedule for next 12 recurrences
      final reminderDate = nextDue.subtract(Duration(days: bill.reminderDays));
      if (reminderDate.isAfter(DateTime.now())) {
        await NotificationService.scheduleBillReminder(
          id: '${bill.id}_$i'.hashCode,
          title: 'Upcoming Bill: ${bill.name}',
          body:
              'Amount: \$${bill.amount} due on ${nextDue.toLocal().toString().split(' ')[0]}',
          scheduledDate: reminderDate,
        );
      }
      if (bill.recurrence == 'monthly') {
        nextDue = DateTime(nextDue.year, nextDue.month + 1, nextDue.day);
      } else if (bill.recurrence == 'weekly') {
        nextDue = nextDue.add(const Duration(days: 7));
      } else if (bill.recurrence == 'yearly') {
        nextDue = DateTime(nextDue.year + 1, nextDue.month, nextDue.day);
      } else {
        break;
      }
    }
    return null;
  }

  Future<String?> updateBill(BillModel bill) async {
    return await _billService.updateBill(bill);
  }

  Future<String?> markBillPaid(String billId) async {
    return await _billService.markBillPaid(billId);
  }
}
