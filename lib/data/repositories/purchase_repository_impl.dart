import 'dart:developer' as dev;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/repositories/purchase_repository.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final SupabaseClient _client;

  PurchaseRepositoryImpl(this._client);

  @override
  Future<Purchase> createPurchase(Purchase purchase) async {
    try {
      // Convert the list of purchase items into a JSON array format
      // that the PostgreSQL function can understand.
      final itemsJson = purchase.items
          .map((item) => {
                'product_item_id': item.productItemId,
                'quantity_ordered': item.quantityOrdered,
                'unit_cost': item.unitCost,
              })
          .toList();

      // Call the 'create_purchase' database function
      final newPurchaseId = await _client.rpc('create_purchase', params: {
        'p_supplier_id': purchase.supplierId,
        'p_po_number': purchase.poNumber,
        'p_payment_method': purchase.paymentMethod.toJson(),
        'p_purchase_date': purchase.purchaseDate.toIso8601String(),
        'p_total_amount': purchase.totalAmount,
        'p_items': itemsJson,
      });

      // After creation, fetch the complete purchase details to return
      final newPurchase = await getPurchaseById(newPurchaseId);
      
      // A purchase that was just created should always be found.
      // If not, something went wrong.
      if (newPurchase == null) {
        throw Exception('Failed to retrieve the new purchase after creation.');
      }
      
      return newPurchase;
    } catch (e) {
      // Provide a more specific error message for debugging
      throw Exception('An error occurred while creating the purchase: $e');
    }
  }

  @override
  Future<Purchase?> getPurchaseById(int id) async {
    final response = await _client
        .from('purchase')
        .select('*, purchase_items(*, product_items(*, products(name)))')
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }
    return Purchase.fromMap(response);
  }

  @override
  Future<List<Purchase>> getPurchases() async {
    try {
      final response = await _client.rpc('get_purchases');
      final data = response as List<dynamic>;
      return data.map((json) => Purchase.fromMap(json)).toList();
    } catch (e) {
      //print('Error during purchase mapping: $e');
      dev.log('Error during purchase mapping: $e');
      throw Exception('Failed to fetch purchases: $e');
    }
  }

  @override
  Future<Purchase> updatePurchase(Purchase purchase) async {
    // Note: A proper update should ideally be another RPC function
    // to handle complex cases like item changes. This is a simple update.
    if (purchase.id == null) {
      throw ArgumentError('Purchase ID cannot be null for an update operation.');
    }
    final response = await _client
        .from('purchase')
        .update(purchase.toMap())
        .eq('id', purchase.id!) // Use ! to assert that id is not null
        .select()
        .single();
    return Purchase.fromMap(response);
  }

  @override
  Future<void> cancelPurchase(int id) async {
    try {
      // Call the 'cancel_purchase' database function
      await _client.rpc('cancel_purchase', params: {'p_purchase_id': id});
    } catch (e) {
      throw Exception('An error occurred while canceling the purchase: $e');
    }
  }
}
