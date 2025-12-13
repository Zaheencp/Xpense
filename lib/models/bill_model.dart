class BillModel {
  final String id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String? notes;
  final String? recurrence; // e.g., 'monthly', 'weekly', 'yearly', or null
  final int reminderDays; // how many days before due date to remind
  final String? calendarEventId;

  BillModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
    this.notes,
    this.recurrence,
    this.reminderDays = 1,
    this.calendarEventId,
  });
}
