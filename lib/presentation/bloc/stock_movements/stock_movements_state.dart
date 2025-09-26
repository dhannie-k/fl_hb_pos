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
  final DateTime? startDate;
  final DateTime? endDate;

  const StockMovementsLoaded({
    required this.movements,
    this.direction,
    this.type,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [movements, direction, type, startDate, endDate];
}

class StockMovementsError extends StockMovementsState {
  final String message;

  const StockMovementsError(this.message);

  @override
  List<Object?> get props => [message];
}
