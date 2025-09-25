import 'package:equatable/equatable.dart';
import '../../../domain/entities/stock_movement.dart';

abstract class StockMovementsState extends Equatable {
  const StockMovementsState();

  @override
  List<Object?> get props => [];
}

class StockMovementsInitial extends StockMovementsState {}

class StockMovementsLoading extends StockMovementsState {}

class StockMovementsLoaded extends StockMovementsState {
  final List<StockMovement> movements;
  final String? direction;
  final String? type;

  const StockMovementsLoaded({
    required this.movements,
    this.direction,
    this.type,
  });

  @override
  List<Object?> get props => [movements, direction, type];
}

class StockMovementsError extends StockMovementsState {
  final String message;

  const StockMovementsError(this.message);

  @override
  List<Object?> get props => [message];
}
