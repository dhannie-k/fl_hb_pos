import '../../../domain/entities/ledger_entry.dart';

abstract class ItemMovementsState {}

class ItemMovementsLoading extends ItemMovementsState {}

class ItemMovementsError extends ItemMovementsState {
  final String message;
  ItemMovementsError(this.message);
}

class ItemMovementsLoaded extends ItemMovementsState {
  final List<LedgerEntry> entries;
  ItemMovementsLoaded(this.entries);
}
