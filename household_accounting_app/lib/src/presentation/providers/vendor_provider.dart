import 'package:flutter/material.dart';
import '../domain/entities/vendor.dart';
import '../domain/usecases/vendor_service.dart';

class VendorProvider extends ChangeNotifier {
  final VendorService _vendorService;
  List<Vendor> _vendors = [];

  VendorProvider(this._vendorService);

  List<Vendor> get vendors => _vendors;

  Future<void> loadVendors() async {
    _vendors = await _vendorService.getVendors();
    notifyListeners();
  }

  Future<Vendor> getVendor(int id) async {
    return await _vendorService.getVendor(id);
  }

  Future<void> addVendor(Vendor vendor) async {
    await _vendorService.addVendor(vendor);
    await loadVendors();
    notifyListeners();
  }

  Future<void> updateVendor(Vendor vendor) async {
    await _vendorService.updateVendor(vendor);
    await loadVendors();
    notifyListeners();
  }

  Future<void> deleteVendor(int id) async {
    await _vendorService.deleteVendor(id);
    await loadVendors();
    notifyListeners();
  }
}