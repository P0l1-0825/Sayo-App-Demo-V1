import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../shared/data/mock_data.dart';

class PdfService {
  // SAYO brand colors
  static const _cafe = PdfColor.fromInt(0xFF472913);
  static const _green = PdfColor.fromInt(0xFF2E7D32);
  static const _red = PdfColor.fromInt(0xFFC62828);
  static const _blue = PdfColor.fromInt(0xFF1565C0);
  static const _grey = PdfColor.fromInt(0xFF37474F);
  static const _greyLight = PdfColor.fromInt(0xFF90A4AE);
  static const _beige = PdfColor.fromInt(0xFFE8E0D5);

  static final _dateFmt = DateFormat('dd/MM/yyyy');
  static final _timeFmt = DateFormat('HH:mm');
  static final _moneyFmt = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  // ─── Movimientos PDF ───

  static Future<Uint8List> generateMovimientosPdf(
    List<Transaction> transactions, {
    String? rangoLabel,
  }) async {
    final pdf = pw.Document();

    final ingresos = transactions
        .where((t) => t.isIncome)
        .fold<double>(0, (s, t) => s + t.amount);
    final egresos = transactions
        .where((t) => !t.isIncome)
        .fold<double>(0, (s, t) => s + t.amount);
    final neto = ingresos - egresos;

    final now = DateTime.now();
    final generatedDate = DateFormat('dd/MM/yyyy HH:mm', 'es_MX').format(now);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader('Reporte de Movimientos', rangoLabel),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Account info
          _buildAccountInfo(),
          pw.SizedBox(height: 12),

          // Summary
          _buildSummaryRow('Total Ingresos', ingresos, _green),
          _buildSummaryRow('Total Egresos', egresos, _red),
          pw.Divider(color: _beige, thickness: 0.5),
          _buildSummaryRow('Neto', neto, neto >= 0 ? _green : _red),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generado: $generatedDate  ·  ${transactions.length} operaciones',
            style: pw.TextStyle(fontSize: 8, color: _greyLight),
          ),
          pw.SizedBox(height: 16),

          // Transactions table
          _buildTransactionsTable(transactions),
        ],
      ),
    );

    return pdf.save();
  }

  // ─── Estado de Cuenta PDF ───

  static Future<Uint8List> generateEstadoCuentaPdf(
    String mesLabel,
    List<Transaction> transactions, {
    double saldoInicial = 47520.83,
  }) async {
    final pdf = pw.Document();

    final ingresos = transactions
        .where((t) => t.isIncome)
        .fold<double>(0, (s, t) => s + t.amount);
    final egresos = transactions
        .where((t) => !t.isIncome)
        .fold<double>(0, (s, t) => s + t.amount);
    final saldoFinal = saldoInicial + ingresos - egresos;

    final now = DateTime.now();
    final generatedDate = DateFormat('dd/MM/yyyy HH:mm', 'es_MX').format(now);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader('Estado de Cuenta', mesLabel),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Account info
          _buildAccountInfo(),
          pw.SizedBox(height: 12),

          // Period summary
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _beige, width: 0.5),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Resumen del periodo',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: _grey,
                  ),
                ),
                pw.SizedBox(height: 8),
                _buildSummaryRow('Saldo Inicial', saldoInicial, _blue),
                _buildSummaryRow('(+) Ingresos', ingresos, _green),
                _buildSummaryRow('(-) Egresos', egresos, _red),
                pw.Divider(color: _beige, thickness: 0.5),
                _buildSummaryRow('Saldo Final', saldoFinal, _cafe),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generado: $generatedDate  ·  ${transactions.length} operaciones',
            style: pw.TextStyle(fontSize: 8, color: _greyLight),
          ),
          pw.SizedBox(height: 16),

          // Transactions table
          _buildTransactionsTable(transactions),
        ],
      ),
    );

    return pdf.save();
  }

  // ─── Shared builders ───

  static pw.Widget _buildHeader(String title, String? subtitle) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SAYO',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: _cafe,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: _grey,
                ),
              ),
              if (subtitle != null)
                pw.Text(
                  subtitle,
                  style: pw.TextStyle(fontSize: 10, color: _greyLight),
                ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF5F0EB),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'SOLVENDOM SOFOM E.N.R.',
              style: pw.TextStyle(fontSize: 8, color: _cafe),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _beige, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'SOLVENDOM SOFOM E.N.R. — Documento informativo',
            style: pw.TextStyle(fontSize: 7, color: _greyLight),
          ),
          pw.Text(
            'Pagina ${context.pageNumber} de ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 7, color: _greyLight),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAccountInfo() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF9F7F4),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _infoLine('Titular', MockUser.fullName),
                _infoLine('CLABE', MockUser.clabe),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _infoLine('RFC', MockEmployment.rfc),
                _infoLine('Email', MockUser.email),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(fontSize: 8, color: _greyLight),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: _grey,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryRow(String label, double amount, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 10, color: _grey)),
          pw.Text(
            _moneyFmt.format(amount),
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTransactionsTable(List<Transaction> transactions) {
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(color: _beige, width: 0.5),
      headerStyle: pw.TextStyle(
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: _cafe),
      cellStyle: pw.TextStyle(fontSize: 8, color: _grey),
      cellHeight: 22,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
      headers: ['Fecha', 'Hora', 'Concepto', 'Referencia', 'Ingreso', 'Egreso'],
      data: sorted.map((tx) {
        final ref = 'REF${tx.id.padLeft(8, '0')}';
        return [
          _dateFmt.format(tx.date),
          _timeFmt.format(tx.date),
          '${tx.title}\n${tx.subtitle}',
          ref,
          tx.isIncome ? _moneyFmt.format(tx.amount) : '',
          !tx.isIncome ? _moneyFmt.format(tx.amount) : '',
        ];
      }).toList(),
    );
  }
}
