import '../entities/bill.dart';
import '../entities/vendor.dart';

abstract class IBillRepository {
  Future<List<Bill>> getBills();
  Future<Bill> getBill(int id);
  Future<void> addBill(Bill bill);
  Future<void> updateBill(Bill bill);
  Future<void> deleteBill(int id);
  Future<List<Bill>> fetchBillsFromBBPS(Vendor vendor, String customerId);
}