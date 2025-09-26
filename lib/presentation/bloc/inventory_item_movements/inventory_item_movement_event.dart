
abstract class ItemMovementsEvent {}

class LoadItemMovements extends ItemMovementsEvent {
  final int itemId;
  final DateTime? startDate;
  final DateTime? endDate;

  LoadItemMovements(this.itemId, {this.startDate, this.endDate});
}
