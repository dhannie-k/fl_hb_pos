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

class InventoryError extends InventoryState {
  final String message;
  const InventoryError(this.message);
}

class InventoryItemLoaded extends InventoryState {
  final InventoryItem item;
  const InventoryItemLoaded(this.item);

  @override
  List<Object?> get props => [item];
}

