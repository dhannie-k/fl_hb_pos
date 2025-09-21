import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/product_service.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductService _productService;

  ProductBloc({required ProductService productService})
    : _productService = productService,
      super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<CreateProduct>(_onAddProduct);
    on<AddProductItem>(_onAddProductItem);
    on<UpdateProduct>(_onUpdateProduct);
    on<UpdateProductItem>(_onUpdateProductItem);
    on<DeleteProduct>(_onDeleteProduct);
    on<DeleteProductItem>(_onDeleteProductItem);
    on<LoadProductDisplayDetail>(_onLoadProductDisplayDetail);
  }
  ProductService get productService => _productService;

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(const ProductLoading());
      final products = await _productService.getProductDisplayItems();
      emit(ProductLoaded(products: products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(const ProductLoading());
      final products = await _productService.searchProductDisplayItems(
        event.query,
      );
      emit(
        ProductLoaded(
          products: products,
          searchQuery: event.query.isNotEmpty ? event.query : null,
        ),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onAddProduct(
    CreateProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(const ProductLoading());
      await _productService.createProduct(event.product);
      emit(const ProductOperationSuccess('Product added successfully'));
      add(const LoadProducts()); // Reload products
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onAddProductItem(
  AddProductItem event,
  Emitter<ProductState> emit,
) async {
  try {
    await _productService.createProductItemWithInitialQuantity(
      event.productItem,
      event.initialQuantity,
    );

    emit(ProductOperationSuccess('Product item added successfully', stayOnPage: event.stayOnPage,));

    // Trigger product reload — let _onLoadProducts handle the ProductLoaded state
    add(const LoadProducts());
  } catch (e) {
    final errorMsg = e.toString();
    if (errorMsg.contains('unique_product_spec')) {
      emit(const ProductOperationError(
        'This specification already exists for this product',
      ));
    } else {
      emit(ProductOperationError('Failed to add product item: $errorMsg'));
    }

    // optional: reload products on error
    final products = await _productService.getProductDisplayItems();
    emit(ProductLoaded(products: products));
  }
}

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _productService.updateProduct(event.product);
      emit(const ProductOperationSuccess('Product updated successfully'));
      add(const LoadProducts()); // Reload products
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onUpdateProductItem(
    UpdateProductItem event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _productService.updateProductItem(event.productItem);
      emit(const ProductOperationSuccess('Product item updated successfully'));
      add(const LoadProducts()); // Reload products
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _productService.deleteProduct(event.productId);
      emit(const ProductOperationSuccess('Product deleted successfully'));
      add(const LoadProducts()); // Reload products
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onDeleteProductItem(
    DeleteProductItem event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _productService.deleteProductItem(event.productItemId);
      emit(const ProductOperationSuccess('Product item deleted successfully'));
      add(const LoadProducts()); // Reload products
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadProductDisplayDetail(
    LoadProductDisplayDetail event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(const ProductLoading());
      final product = await _productService.getProductDisplayItemsById(
        event.productId,
      );
      if (product == null) {
        emit(const ProductError('Product not found'));
        return;
      }
      emit(ProductDisplayDetailLoaded(product));
    } catch (e) {
      emit(ProductError('Failed to load product detail: $e'));
    }
  }
}
