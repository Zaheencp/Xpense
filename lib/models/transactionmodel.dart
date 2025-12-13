import '../services/encryption_service.dart';

class TransactionModel {
  final String id;
  final String category;
  final String amount;
  final String date;
  final String memo;
  final String? location;

  TransactionModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.memo,
    required this.date,
    this.location,
  });

  // Convert the object to a Map for adding to Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': EncryptionService.encryptText(category),
      'amount': amount, // Store as string, handled by encryption
      'memo': EncryptionService.encryptText(memo),
      'date': EncryptionService.encryptText(date),
      'location':
          location != null ? EncryptionService.encryptText(location!) : null,
    };
  }

  // Create an instance of the model from a Map retrieved from Firebase
  factory TransactionModel.fromMap(Map<String, dynamic> transaction) {
    return TransactionModel(
      id: transaction['id'] ?? '',
      category: EncryptionService.decryptText(transaction['category'] ?? ''),
      amount: EncryptionService.decryptText(
          transaction['amount']?.toString() ?? ''), // Decrypt amount
      memo: EncryptionService.decryptText(transaction['memo'] ?? ''),
      date: EncryptionService.decryptText(transaction['date'] ?? ''),
      location: transaction['location'] != null
          ? EncryptionService.decryptText(transaction['location'])
          : null,
    );
  }
}
