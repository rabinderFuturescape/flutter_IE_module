import '../entities/vendor.dart';

abstract class IVendorRepository {
  Future<List<Vendor>> getVendors();
  Future<Vendor> getVendor(int id);
  Future<void> addVendor(Vendor vendor);
  Future<void> updateVendor(Vendor vendor);
  Future<void> deleteVendor(int id);
}