import 'package:flutter/material.dart';
import '../../domain/entities/bill.dart';
import '../../domain/usecases/bill_service.dart';

class BillProvider extends ChangeNotifier {
  final BillService _billService;
  List<Bill> bills = [];

  BillProvider(this._billService);

  Future<void> loadBills() async {
    bills = await _billService.getBills();
    notifyListeners();
  }

  Future<Bill> getBill(int id) async {
    final bill = await _billService.getBill(id);
    return bill;
  }

  Future<void> addBill(Bill bill) async {
    await _billService.addBill(bill);
    bills.add(bill);
    notifyListeners();
  }

  Future<void> updateBill(Bill bill) async {
    await _billService.updateBill(bill);
    final index = bills.indexWhere((b) => b.id == bill.id);
    if (index != -1) {
      bills[index] = bill;
    }
    notifyListeners();
  }

  Future<void> deleteBill(int id) async {
    await _billService.deleteBill(id);
    bills.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  Future<void> fetchBillsFromBBPS(
      Vendor vendor, String customerId) async {
    final fetchedBills =
        await _billService.fetchBillsFromBBPS(vendor, customerId);
    bills.addAll(fetchedBills);
    notifyListeners();
  }
}