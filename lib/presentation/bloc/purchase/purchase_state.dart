import 'package:equatable/equatable.dart';
import '../../../domain/entities/purchase.dart';

abstract class PurchaseState extends Equatable {
  const PurchaseState();

  @override
  List<Object?> get props => [];
}

class PurchaseInitial extends PurchaseState {}

class PurchaseLoading extends PurchaseState {}

class PurchaseOperationSuccess extends PurchaseState {
  final String message;
  const PurchaseOperationSuccess(this.message);
    @override
  List<Object> get props => [message];
}

class PurchasesLoaded extends PurchaseState {
  final List<Purchase> purchases;

  const PurchasesLoaded(this.purchases);
    @override
  List<Object> get props => [purchases];
}

class PurchaseDetailsLoaded extends PurchaseState {
  final Purchase purchase;

  const PurchaseDetailsLoaded(this.purchase);
    @override
  List<Object> get props => [purchase];
}


class PurchaseError extends PurchaseState {
  final String message;

  const PurchaseError(this.message);

  @override
  List<Object> get props => [message];
}

class PurchaseCancelled extends PurchaseState {}
