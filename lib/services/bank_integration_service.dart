import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/transaction_model.dart';

class BankIntegrationService {
  final String baseUrl = 'http://localhost:5000/api/plaid';

  Future<String> linkAccount(String publicToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/link'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'public_token': publicToken}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to link account: ${response.body}');
    }
    final accessToken = jsonDecode(response.body)['accessToken'];
    return accessToken;
  }

  Future<List<TransactionModel>> fetchTransactions(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions?accessToken=$accessToken'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch transactions: ${response.body}');
    }
    final List<dynamic> data = jsonDecode(response.body)['transactions'];
    return data.map((json) => TransactionModel.fromJson(json)).toList();
  }
}
