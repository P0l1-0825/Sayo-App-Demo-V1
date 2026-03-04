import 'package:intl/intl.dart';
import '../../shared/data/mock_data.dart';

class CsvService {
  static String generateMovimientosCsv(List<Transaction> transactions) {
    final buf = StringBuffer();
    // UTF-8 BOM for Excel compatibility
    buf.write('\uFEFF');
    buf.writeln('Fecha,Hora,Concepto,Detalle,Referencia,Tipo,Monto');

    final dateFmt = DateFormat('dd/MM/yyyy');
    final timeFmt = DateFormat('HH:mm:ss');

    for (final tx in transactions) {
      final date = dateFmt.format(tx.date);
      final time = timeFmt.format(tx.date);
      final concept = _escapeCsv(tx.title);
      final detail = _escapeCsv(tx.subtitle);
      final ref = 'REF${tx.id.padLeft(8, '0')}';
      final type = tx.isIncome ? 'Ingreso' : 'Egreso';
      final amount = tx.isIncome
          ? tx.amount.toStringAsFixed(2)
          : '-${tx.amount.toStringAsFixed(2)}';

      buf.writeln('$date,$time,$concept,$detail,$ref,$type,$amount');
    }

    return buf.toString();
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
