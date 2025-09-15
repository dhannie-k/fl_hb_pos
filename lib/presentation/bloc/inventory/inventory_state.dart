import '../../../domain/entities/inventory.dart';
import 'package:equatable/equatable.dart';


abstract class InventoryState extends Equatable {
  const InventoryState();
  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryItem> items;
  final String? message;
  const InventoryLoaded(this.items, {this.message});
}
class InventoryOperationSuccess extends InventoryState {
  final String message;
  const InventoryOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}


class InventoryError extends InventoryState {
  final String message;
  const InventoryError(this.message);
}
