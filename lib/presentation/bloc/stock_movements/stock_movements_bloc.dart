import 'package:flutter_bloc/flutter_bloc.dart';
import 'stock_movements_event.dart';
import 'stock_movements_state.dart';
import '../../../data/datasources/supabase_datasource.dart';

class StockMovementsBloc extends Bloc<StockMovementsEvent, StockMovementsState> {
  final SupabaseDatasource dataSource;

  StockMovementsBloc(this.dataSource) : super(StockMovementsInitial()) {
    on<LoadStockMovements>(_onLoadStockMovements);
    on<RefreshStockMovements>(_onRefreshStockMovements);
  }

  Future<void> _onLoadStockMovements(
       LoadStockMovements event,
    Emitter<StockMovementsState> emit,
  ) async {
    emit(StockMovementsLoading());
    try {
      final movements = await dataSource.getStockMovements(
        startDate: event.startDate,
        endDate: event.endDate,
        direction: event.direction,
        type: event.type,
      );
      emit(StockMovementsLoaded(
        movements: movements,
        direction: event.direction,
        type: event.type,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(StockMovementsError(e.toString()));
    }
  }

  Future<void> _onRefreshStockMovements(
      RefreshStockMovements event,
    Emitter<StockMovementsState> emit,
  ) async {
    if (state is StockMovementsLoaded) {
      final current = state as StockMovementsLoaded;
      add(LoadStockMovements(
        direction: current.direction,
        type: current.type,
        startDate: current.startDate,
        endDate: current.endDate,
      ));
    } else {
      add(const LoadStockMovements());
    }
  }
}
