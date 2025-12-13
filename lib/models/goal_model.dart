class GoalModel {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String? notes;

  GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    this.notes,
  });
}
