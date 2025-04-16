import 'dart:async';
import '../repositories/i_bill_repository.dart';
import '../entities/bill.dart';
import '../entities/vendor.dart';

class BillService {
  final IBillRepository _billRepository;

  BillService(this._billRepository);

  Future<List<Bill>> getBills() {
    return _billRepository.getBills();
  }

  Future<Bill> getBill(int id) {
    return _billRepository.getBill(id);
  }

  Future<void> addBill(Bill bill) {
    return _billRepository.addBill(bill);
  }

  Future<void> updateBill(Bill bill) {
    return _billRepository.updateBill(bill);
  }

  Future<void> deleteBill(int id) {
    return _billRepository.deleteBill(id);
  }

  Future<List<Bill>> fetchBillsFromBBPS(Vendor vendor, String customerId) {
    return _billRepository.fetchBillsFromBBPS(vendor, customerId);
  }
}