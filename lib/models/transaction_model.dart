class TransactionModel {
  final String id;
  final String description;
  final double amount;
  final String date;
  final String category;
  final String? location; // Added location field

  TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    this.location,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      date: json['date'],
      category: json['category'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
        'date': date,
        'category': category,
        'location': location,
      };
}
