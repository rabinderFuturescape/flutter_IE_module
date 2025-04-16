import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:household_accounting_app/src/domain/entities/vendor.dart';
import 'package:household_accounting_app/src/domain/repositories/i_vendor_repository.dart';
import 'package:household_accounting_app/src/domain/usecases/vendor_service.dart';

class MockVendorRepository extends Mock implements IVendorRepository {}

void main() {
  late VendorService vendorService;
  late MockVendorRepository mockVendorRepository;

  setUp(() {
    mockVendorRepository = MockVendorRepository();
    vendorService = VendorService(mockVendorRepository);
  });

  final testVendor = Vendor(id: 1, name: 'Test Vendor');

  group('VendorService', () {
    test('getVendors should return a list of vendors', () async {
      final expectedVendors = [testVendor];
      when(
        mockVendorRepository.getVendors(),
      ).thenAnswer((_) async => expectedVendors);

      final result = await vendorService.getVendors();

      expect(result, equals(expectedVendors));
      verify(mockVendorRepository.getVendors()).called(1);
    });

    test('getVendor should return a vendor by id', () async {
      when(
        mockVendorRepository.getVendor(1),
      ).thenAnswer((_) async => testVendor);

      final result = await vendorService.getVendor(1);

      expect(result, equals(testVendor));
      verify(mockVendorRepository.getVendor(1)).called(1);
    });

    test('addVendor should add a vendor', () async {
      when(
        mockVendorRepository.addVendor(testVendor),
      ).thenAnswer((_) async => {});

      await vendorService.addVendor(testVendor);

      verify(mockVendorRepository.addVendor(testVendor)).called(1);
    });

    test('updateVendor should update a vendor', () async {
      when(
        mockVendorRepository.updateVendor(testVendor),
      ).thenAnswer((_) async => {});

      await vendorService.updateVendor(testVendor);

      verify(mockVendorRepository.updateVendor(testVendor)).called(1);
    });

    test('deleteVendor should delete a vendor by id', () async {
      when(mockVendorRepository.deleteVendor(1)).thenAnswer((_) async => {});

      await vendorService.deleteVendor(1);

      verify(mockVendorRepository.deleteVendor(1)).called(1);
    });
  });
}
