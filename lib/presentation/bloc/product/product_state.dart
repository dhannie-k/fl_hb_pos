import 'package:equatable/equatable.dart';
import '../../../domain/repositories/product_service.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<ProductDisplayItem> products;
  final String? searchQuery;

  const ProductLoaded({
    required this.products,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [products, searchQuery];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductOperationSuccess extends ProductState {
  final String message;

  const ProductOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductOperationError extends ProductState {
  final String message;
  const ProductOperationError(this.message);
}

class ProductDisplayDetailLoaded extends ProductState {
  final ProductDisplayItem product;

  const ProductDisplayDetailLoaded(this.product);

  @override
  List<Object?> get props => [product];
}
