import 'package:equatable/equatable.dart';
import '../../../domain/entities/purchase.dart';

abstract class PurchaseEvent extends Equatable {
  const PurchaseEvent();

  @override
  List<Object> get props => [];
}

class AddPurchase extends PurchaseEvent {
  final Purchase purchase;

  const AddPurchase(this.purchase);

  @override
  List<Object> get props => [purchase];
}

class LoadPurchases extends PurchaseEvent {}

class LoadPurchaseDetails extends PurchaseEvent {
  final int purchaseId;

  const LoadPurchaseDetails(this.purchaseId);
    @override
  List<Object> get props => [purchaseId];
}
