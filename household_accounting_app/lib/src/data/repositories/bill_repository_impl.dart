import 'dart:async';
import 'package:household_accounting_app/src/domain/entities/bill.dart';
import 'package:household_accounting_app/src/domain/entities/vendor.dart';
import 'package:household_accounting_app/src/domain/repositories/i_bill_repository.dart';

class BillRepositoryImpl implements IBillRepository {
  final List<Bill> _bills = [];
  int _nextId = 1;

  @override
  Future<List<Bill>> getBills() async {
    return _bills;
  }

  @override
  Future<Bill> getBill(int id) async {
    return _bills.firstWhere((bill) => bill.id == id);
  }

  @override
  Future<void> addBill(Bill bill) async {
    bill.id = _nextId++;
    _bills.add(bill);
  }

  @override
  Future<void> updateBill(Bill bill) async {
    final index = _bills.indexWhere((b) => b.id == bill.id);
    if (index != -1) {
      _bills[index] = bill;
    }
  }

  @override
  Future<void> deleteBill(int id) async {
    _bills.removeWhere((bill) => bill.id == id);
  }

  @override
  Future<List<Bill>> fetchBillsFromBBPS(Vendor vendor, String customerId) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dayAfterTomorrow = DateTime.now().add(const Duration(days: 2));

    final bill1 = Bill(
      id: 1,
      vendorId: vendor.id!,
      amount: 100.0,
      dueDate: tomorrow,
      billNumber: 'BILL001',
      billPeriod: '202401',
      isPaid: false,
    );

    final bill2 = Bill(
      id: 2,
      vendorId: vendor.id!,
      amount: 200.0,
      dueDate: dayAfterTomorrow,
      billNumber: 'BILL002',
      billPeriod: '202402',
      isPaid: false,
    );

    return [bill1, bill2];
  }
}