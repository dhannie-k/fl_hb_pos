import 'package:equatable/equatable.dart';

abstract class StockMovementsEvent extends Equatable{
  const StockMovementsEvent();

   @override
  List<Object?> get props => [];
}

class LoadStockMovements extends StockMovementsEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? direction; // 'in', 'out', or null
  final String? type;      // purchase, sale, adjustment, etc.

  const LoadStockMovements({
    this.startDate,
    this.endDate,
    this.direction,
    this.type,
  });

  @override
  List<Object?> get props => [startDate, endDate, direction, type];
}

class RefreshStockMovements extends StockMovementsEvent {}
