import 'package:intl/intl.dart';

String formatMoney(double amount, {String symbol = r'$'}) {
  final f = NumberFormat('#,##0.00', 'es_MX');
  return '$symbol${f.format(amount)}';
}

String formatPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 10) {
    return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
  }
  return phone;
}

String formatClabe(String clabe) {
  if (clabe.length == 18) {
    return '${clabe.substring(0, 3)} ${clabe.substring(3, 6)} ${clabe.substring(6, 10)} ${clabe.substring(10, 14)} ${clabe.substring(14)}';
  }
  return clabe;
}

String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy', 'es_MX').format(date);
}

String formatTime(DateTime date) {
  return DateFormat('HH:mm', 'es_MX').format(date);
}

String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'Ahora';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
  if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
  return formatDate(date);
}
