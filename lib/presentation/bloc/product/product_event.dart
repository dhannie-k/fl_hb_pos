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

class CreateProduct extends ProductEvent {
  final Product product;

  const CreateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class AddProductItem extends ProductEvent {
  final ProductItem productItem;
  final int initialQuantity;

  const AddProductItem(this.productItem, {this.initialQuantity = 0});

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


class LoadProductDisplayDetail extends ProductEvent {
  final int productId;
  const LoadProductDisplayDetail(this.productId);

  @override
  List<Object?> get props => [productId];
}


