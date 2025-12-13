/// Model representing a budget.
class BudgetModel {
  final String id;
  final String name;
  final double amount;
  final String category;

  BudgetModel(
      {required this.id,
      required this.name,
      required this.amount,
      required this.category});
}
