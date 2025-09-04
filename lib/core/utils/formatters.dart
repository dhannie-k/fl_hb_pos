import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat currency = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  
  static final NumberFormat number = NumberFormat('#,##0');
  
  static final DateFormat date = DateFormat('MMM dd, yyyy');
  
  static final DateFormat dateTime = DateFormat('MMM dd, yyyy HH:mm');
  
  static String formatCurrency(double amount) {
    return currency.format(amount);
  }
  
  static String formatNumber(int number) {
    return AppFormatters.number.format(number);
  }
  
  static String formatDate(DateTime date) {
    return AppFormatters.date.format(date);
  }
  
  static String formatDateTime(DateTime dateTime) {
    return AppFormatters.dateTime.format(dateTime);
  }
}