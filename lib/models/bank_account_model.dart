/// Model representing a linked bank account.
class BankAccountModel {
  final String id;
  final String name;
  final String accountNumber;

  BankAccountModel(
      {required this.id, required this.name, required this.accountNumber});

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'],
      name: json['name'],
      accountNumber: json['accountNumber'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'accountNumber': accountNumber,
      };
}
