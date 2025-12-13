import 'bank_integration_service.dart';

class TransactionSyncService {
  final BankIntegrationService _bankService = BankIntegrationService();

  Future<void> syncTransactions(String accessToken) async {
    // TODO: Fetch and update transactions from the backend
    await _bankService.fetchTransactions(accessToken);
    // TODO: Update local storage or state with new transactions
  }
}
