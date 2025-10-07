import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupabaseClient _client;

  SupplierRepositoryImpl(this._client);

  @override
  Future<List<Supplier>> getSuppliers() async {
    final response = await _client.rpc('get_suppliers');
    final data = response as List<dynamic>;
    return data.map((json) => Supplier.fromMap(json)).toList();
  }

  @override
  Future<Supplier> addSupplier({
    required String name,
    String? address,
    String? phoneNumber,
  }) async {
    final response = await _client.rpc('add_supplier', params: {
      'p_name': name,
      'p_address': address,
      'p_phone_number': phoneNumber,
    }).single();
    return Supplier.fromMap(response);
  }

  @override
  Future<Supplier> updateSupplier(Supplier supplier) async {
    final response = await _client.rpc('update_supplier', params: {
      'p_id': supplier.id,
      'p_name': supplier.name,
      'p_address': supplier.address,
      'p_phone_number': supplier.phoneNumber,
    }).single();
    return Supplier.fromMap(response);
  }

  @override
  Future<void> deleteSupplier(int id) async {
    await _client.rpc('delete_supplier', params: {'p_id': id});
  }
  
  @override
  Future<List<Supplier>> searchSuppliers(String query) async{
    final response = await _client.rpc('search_suppliers', params:{'p_search_term': query});
    final data = response as List<dynamic>;
    return data.map((json) => Supplier.fromMap(json)).toList();
  }
}
