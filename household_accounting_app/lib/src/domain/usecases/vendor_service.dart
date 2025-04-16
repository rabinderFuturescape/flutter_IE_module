import 'dart:async';
import '../domain/entities/vendor.dart';
import '../domain/repositories/i_vendor_repository.dart';

class VendorService {
  final IVendorRepository vendorRepository;

  VendorService(this.vendorRepository);

  Future<List<Vendor>> getVendors() {
    return vendorRepository.getVendors();
  }

  Future<Vendor> getVendor(int id) {
    return vendorRepository.getVendor(id);
  }

  Future<void> addVendor(Vendor vendor) {
    return vendorRepository.addVendor(vendor);
  }

  Future<void> updateVendor(Vendor vendor) {
    return vendorRepository.updateVendor(vendor);
  }

  Future<void> deleteVendor(int id) {
    return vendorRepository.deleteVendor(id);
  }
}
