import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/services/pdf_service.dart';
import '../../core/services/web_download.dart';
import '../../shared/data/mock_data.dart';

class EstadosCuentaScreen extends StatefulWidget {
  const EstadosCuentaScreen({super.key});

  @override
  State<EstadosCuentaScreen> createState() => _EstadosCuentaScreenState();
}

class _EstadosCuentaScreenState extends State<EstadosCuentaScreen> {
  late List<_MonthData> _months;
  int _selectedIndex = 0;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _months = _buildMonths();
  }

  List<_MonthData> _buildMonths() {
    final now = DateTime.now();
    final result = <_MonthData>[];

    for (int i = 0; i < 6; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthStart = DateTime(date.year, date.month, 1);
      final monthEnd = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

      final txns = mockTransactionsExtended
          .where((t) => t.date.isAfter(monthStart.subtract(const Duration(seconds: 1))) && t.date.isBefore(monthEnd.add(const Duration(seconds: 1))))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      final label = DateFormat('MMMM yyyy', 'es_MX').format(date);
      final shortLabel = DateFormat('MMM', 'es_MX').format(date).toUpperCase();

      result.add(_MonthData(
        date: date,
        label: label,
        shortLabel: shortLabel,
        year: date.year.toString(),
        transactions: txns,
      ));
    }

    return result;
  }

  _MonthData get _selected => _months[_selectedIndex];

  double get _saldoInicial {
    final idx = _selectedIndex;
    return 47520.83 + (idx * 5200.0);
  }

  @override
  Widget build(BuildContext context) {
    final txns = _selected.transactions;
    final ingresos = txns.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
    final egresos = txns.where((t) => !t.isIncome).fold<double>(0, (s, t) => s + t.amount);
    final saldoFinal = _saldoInicial + ingresos - egresos;

    return Scaffold(
      backgroundColor: SayoColors.cream,
      appBar: AppBar(
        backgroundColor: SayoColors.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Estados de Cuenta',
            style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Month selector
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _months.length,
              itemBuilder: (ctx, i) {
                final m = _months[i];
                final selected = i == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: selected ? SayoColors.cafe : SayoColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? SayoColors.cafe : SayoColors.beige, width: selected ? 1.5 : 0.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(m.shortLabel, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w800, color: selected ? SayoColors.white : SayoColors.gris)),
                        const SizedBox(height: 2),
                        Text(m.year, style: GoogleFonts.urbanist(fontSize: 11, color: selected ? Colors.white.withValues(alpha: 0.7) : SayoColors.grisLight)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: selected ? Colors.white.withValues(alpha: 0.2) : SayoColors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${m.transactions.length}',
                            style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w700, color: selected ? SayoColors.white : SayoColors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Period summary
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SayoColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SayoColors.beige, width: 0.5),
              ),
              child: Column(
                children: [
                  Text(
                    'Resumen — ${_selected.label}',
                    style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w800, color: SayoColors.gris),
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(label: 'Saldo Inicial', amount: _saldoInicial, color: SayoColors.blue),
                  const SizedBox(height: 8),
                  _SummaryRow(label: '(+) Ingresos', amount: ingresos, color: SayoColors.green),
                  const SizedBox(height: 8),
                  _SummaryRow(label: '(-) Egresos', amount: egresos, color: SayoColors.red),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: SayoColors.beige, height: 1),
                  ),
                  _SummaryRow(label: 'Saldo Final', amount: saldoFinal, color: SayoColors.cafe, bold: true),
                ],
              ),
            ),
          ),

          // Transactions header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: Row(
              children: [
                Text('Movimientos del periodo', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.grisMed)),
                const Spacer(),
                Text('${txns.length} operaciones', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisLight)),
              ],
            ),
          ),

          // Transactions list
          Expanded(
            child: txns.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_rounded, size: 48, color: SayoColors.beige),
                        const SizedBox(height: 12),
                        Text('Sin movimientos', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.grisMed)),
                        const SizedBox(height: 4),
                        Text('No hay movimientos en este mes', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: txns.length,
                    itemBuilder: (ctx, i) => _TransactionTile(tx: txns[i]),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: ElevatedButton.icon(
            onPressed: _downloading ? null : () => _downloadEstadoCuenta(ingresos, egresos, saldoFinal),
            style: ElevatedButton.styleFrom(
              backgroundColor: SayoColors.cafe,
              foregroundColor: SayoColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            icon: _downloading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: SayoColors.white))
                : const Icon(Icons.download_rounded, size: 18),
            label: Text(
              _downloading ? 'Generando...' : 'Descargar Estado de Cuenta',
              style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadEstadoCuenta(double ingresos, double egresos, double saldoFinal) async {
    setState(() => _downloading = true);
    try {
      final bytes = await PdfService.generateEstadoCuentaPdf(
        _selected.label,
        _selected.transactions,
        saldoInicial: _saldoInicial,
      );
      final monthKey = DateFormat('yyyy_MM').format(_selected.date);
      final filename = 'SAYO_EstadoCuenta_$monthKey.pdf';
      downloadBytes(bytes, filename, 'application/pdf');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado de cuenta descargado', style: GoogleFonts.urbanist()),
            backgroundColor: SayoColors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF', style: GoogleFonts.urbanist()),
            backgroundColor: SayoColors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }
}

// ─── Models ───

class _MonthData {
  final DateTime date;
  final String label;
  final String shortLabel;
  final String year;
  final List<Transaction> transactions;

  const _MonthData({
    required this.date,
    required this.label,
    required this.shortLabel,
    required this.year,
    required this.transactions,
  });
}

// ─── Widgets ───

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool bold;

  const _SummaryRow({required this.label, required this.amount, required this.color, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color: SayoColors.gris,
          ),
        ),
        Text(
          formatMoney(amount),
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SayoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SayoColors.beige, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: tx.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(tx.icon, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                const SizedBox(height: 1),
                Text(tx.subtitle, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${tx.isIncome ? '+' : '-'}${formatMoney(tx.amount)}',
                style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: tx.isIncome ? SayoColors.green : SayoColors.gris),
              ),
              const SizedBox(height: 1),
              Text('${formatDate(tx.date)}  ${formatTime(tx.date)}', style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
            ],
          ),
        ],
      ),
    );
  }
}
