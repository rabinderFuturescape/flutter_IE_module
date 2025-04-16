import 'entry_type.dart'; // Assuming entry_type.dart is in the same directory

class Ledger {
  final String id;
  final String name;
  double balance;
  final String groupId;

  Ledger({
    required this.id,
    required this.name,
    this.balance = 0.0,
    required this.groupId,
  });

  void updateBalance(double amount, EntryType entryType) {
    // Logic based on accounting principles (e.g., Assets increase with Debit)
    // This might need refinement based on the groupId (Asset/Liability/Equity/Income/Expense)
    // For simplicity, let's stick to the original logic for now.
    if (entryType == EntryType.debit) {
      balance += amount;
    } else {
      balance -= amount;
    }
  }

  // For Database Interaction
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'balance': balance, 'groupId': groupId};
  }

  factory Ledger.fromMap(Map<String, dynamic> map) {
    return Ledger(
      id: map['id'] as String,
      name: map['name'] as String,
      balance: map['balance'] as double,
      groupId: map['groupId'] as String,
    );
  }
}
