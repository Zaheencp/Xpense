/// Model representing an expense category.
class CategoryModel {
  final String id;
  final String name;
  final String? icon;

  CategoryModel({required this.id, required this.name, this.icon});
}
