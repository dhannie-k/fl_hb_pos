class LedgerEntry {
  final DateTime timestamp;
  final String type; // purchase, sale, adjustment, carried_forward
  final double qtyChange;
  final double balance;
  final String? note;

  LedgerEntry({
    required this.timestamp,
    required this.type,
    required this.qtyChange,
    required this.balance,
    this.note,
  });
}
