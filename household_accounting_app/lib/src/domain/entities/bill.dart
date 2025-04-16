int? id;
int? vendorId;
double? amount;
DateTime? dueDate;
String? billNumber;
String? billPeriod;
bool? isPaid;

class Bill {
  final int id;
  final int vendorId;
  final double amount;
  final DateTime dueDate;
  final String billNumber;
  final String billPeriod;
  final bool isPaid;

  Bill({
    required this.id,
    required this.vendorId,
    required this.amount,
    required this.dueDate,
    required this.billNumber,
    required this.billPeriod,
    required this.isPaid,
  });
}
