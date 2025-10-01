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
  final List<InventoryItem>? searchResults;
  final String? message;
  const InventoryLoaded(this.items, {this.searchResults, this.message});

  InventoryLoaded copyWith({
    List<InventoryItem>? items,
    List<InventoryItem>? searchResults,
    String? message,
  }) {
    return InventoryLoaded(
      items ?? this.items,
      searchResults: searchResults ?? this.searchResults,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [items, searchResults, message];
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

