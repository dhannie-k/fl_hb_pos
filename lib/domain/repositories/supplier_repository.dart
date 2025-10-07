import '../entities/supplier.dart';

abstract class SupplierRepository {
  Future<List<Supplier>> getSuppliers();
  Future<Supplier> addSupplier(
      {required String name, String? address, String? phoneNumber});
  Future<Supplier> updateSupplier(Supplier supplier);
  Future<void> deleteSupplier(int id);
   Future<List<Supplier>> searchSuppliers(String query);
}
