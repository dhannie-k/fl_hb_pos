part of 'supplier_bloc.dart';


abstract class SupplierEvent extends Equatable {
  const SupplierEvent();
  @override
  List<Object?> get props => [];
}

class LoadSuppliers extends SupplierEvent {}

class AddSupplier extends SupplierEvent {
  final String name;
  final String? address;
  final String? phoneNumber;
  const AddSupplier({required this.name, this.address, this.phoneNumber});
}

class UpdateSupplier extends SupplierEvent {
  final Supplier supplier;
  const UpdateSupplier(this.supplier);
}

class DeleteSupplier extends SupplierEvent {
  final int id;
  const DeleteSupplier(this.id);
}

class SearchSuppliers extends SupplierEvent {
  final String query;
  const SearchSuppliers(this.query);
}
