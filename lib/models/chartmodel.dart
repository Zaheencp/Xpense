import 'package:flutter/material.dart';
import '../services/encryption_service.dart';

class ChartModel {
  final String category;
  final double amount;
  final Color? color;

  ChartModel(this.category, this.amount, [this.color]);

  factory ChartModel.fromfirebase(Map<String, dynamic> data) {
    // Decrypt the category and amount
    final decryptedCategory = data['category'] is String
        ? EncryptionService.decryptText(data['category'])
        : data['category'].toString();

    final amountStr = data['amount'] is String
        ? EncryptionService.decryptText(data['amount'])
        : data['amount'].toString();

    final amount = double.tryParse(amountStr) ?? 0.0;

    return ChartModel(decryptedCategory, amount);
  }
}
