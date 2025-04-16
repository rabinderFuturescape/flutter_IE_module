import '../entities/vendor.dart';
import '../repositories/i_vendor_repository.dart';

class VendorRepositoryImpl implements IVendorRepository {
  final List<Vendor> _vendors = [
    Vendor(
      id: 1,
      name: 'Electricity Company',
      bbpsBillerId: 'ELEC001',
      category: 'Electricity',
      isBBPS: true,
    ),
    Vendor(
      id: 2,
      name: 'Water Supplier',
      bbpsBillerId: 'WATER001',
      category: 'Water',
      isBBPS: true,
    ),
  ];
  int _nextId = 3;

  @override
  Future<List<Vendor>> getVendors() async {
    return _vendors;
  }

  @override
  Future<Vendor> getVendor(int id) async {
    return _vendors.firstWhere((vendor) => vendor.id == id);
  }

  @override
  Future<void> addVendor(Vendor vendor) async {
    vendor.id = _nextId++;
    _vendors.add(vendor);
  }

  @override
  Future<void> updateVendor(Vendor vendor) async {
    final index = _vendors.indexWhere((v) => v.id == vendor.id);
    if (index != -1) {
      _vendors[index] = vendor;
    }
  }

  @override
  Future<void> deleteVendor(int id) async {
    _vendors.removeWhere((vendor) => vendor.id == id);
  }
}