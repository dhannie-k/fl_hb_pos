import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  const LoadProducts();
}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class AddProduct extends ProductEvent {
  final Product product;

  const AddProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class AddProductItem extends ProductEvent {
  final ProductItem productItem;

  const AddProductItem(this.productItem);

  @override
  List<Object?> get props => [productItem];
}

class UpdateProduct extends ProductEvent {
  final Product product;

  const UpdateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProductItem extends ProductEvent {
  final ProductItem productItem;

  const UpdateProductItem(this.productItem);

  @override
  List<Object?> get props => [productItem];
}

class DeleteProduct extends ProductEvent {
  final int productId;

  const DeleteProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}

class DeleteProductItem extends ProductEvent {
  final int productItemId;

  const DeleteProductItem(this.productItemId);

  @override
  List<Object?> get props => [productItemId];
}