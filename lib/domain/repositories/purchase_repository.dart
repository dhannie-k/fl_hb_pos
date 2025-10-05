import '../entities/purchase.dart';

abstract class PurchaseRepository {
  Future<Purchase> createPurchase(Purchase purchase);
  Future<Purchase?> getPurchaseById(int id);
  Future<List<Purchase>> getPurchases();
  Future<Purchase> updatePurchase(Purchase purchase);
  Future<void> cancelPurchase(int id);
}
