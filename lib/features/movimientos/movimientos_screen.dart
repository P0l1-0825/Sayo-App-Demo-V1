import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/services/pdf_service.dart';
import '../../core/services/csv_service.dart';
import '../../core/services/web_download.dart';
import '../../shared/data/mock_data.dart';

class MovimientosScreen extends StatefulWidget {
  const MovimientosScreen({super.key});

  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  // Filters
  int _typeFilter = 0; // 0=Todos, 1=Ingresos, 2=Egresos
  DateTimeRange? _dateRange;
  bool _downloading = false;

  List<Transaction> get _filteredTransactions {
    var txns = List<Transaction>.from(mockTransactionsExtended);

    // Type filter
    if (_typeFilter == 1) {
      txns = txns.where((t) => t.isIncome).toList();
    } else if (_typeFilter == 2) {
      txns = txns.where((t) => !t.isIncome).toList();
    }

    // Date filter
    if (_dateRange != null) {
      final start = _dateRange!.start;
      final end = _dateRange!.end.add(const Duration(hours: 23, minutes: 59, seconds: 59));
      txns = txns.where((t) => t.date.isAfter(start.subtract(const Duration(seconds: 1))) && t.date.isBefore(end.add(const Duration(seconds: 1)))).toList();
    }

    txns.sort((a, b) => b.date.compareTo(a.date));
    return txns;
  }

  String get _rangoLabel {
    if (_dateRange != null) {
      final fmt = DateFormat('dd MMM', 'es_MX');
      return '${fmt.format(_dateRange!.start)} — ${fmt.format(_dateRange!.end)}';
    }
    return 'Todos';
  }

  @override
  Widget build(BuildContext context) {
    final txns = _filteredTransactions;
    final ingresos = txns.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
    final egresos = txns.where((t) => !t.isIncome).fold<double>(0, (s, t) => s + t.amount);
    final neto = ingresos - egresos;

    return Scaffold(
      backgroundColor: SayoColors.cream,
      appBar: AppBar(
        backgroundColor: SayoColors.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Movimientos',
            style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: SayoColors.cafe),
            onPressed: () => _showDownloadSheet(txns, ingresos, egresos),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                _FilterChip(label: 'Todos', selected: _typeFilter == 0, onTap: () => setState(() => _typeFilter = 0)),
                const SizedBox(width: 8),
                _FilterChip(label: 'Ingresos', selected: _typeFilter == 1, onTap: () => setState(() => _typeFilter = 1)),
                const SizedBox(width: 8),
                _FilterChip(label: 'Egresos', selected: _typeFilter == 2, onTap: () => setState(() => _typeFilter = 2)),
                const Spacer(),
                GestureDetector(
                  onTap: _pickDateRange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _dateRange != null ? SayoColors.cafe.withValues(alpha: 0.08) : SayoColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _dateRange != null ? SayoColors.cafe : SayoColors.beige, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: _dateRange != null ? SayoColors.cafe : SayoColors.grisMed),
                        const SizedBox(width: 4),
                        Text(
                          _dateRange != null ? _rangoLabel : 'Fecha',
                          style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: _dateRange != null ? SayoColors.cafe : SayoColors.grisMed),
                        ),
                        if (_dateRange != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => _dateRange = null),
                            child: const Icon(Icons.close_rounded, size: 14, color: SayoColors.cafe),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Summary cards
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                Expanded(child: _SummaryCard(label: 'Ingresos', amount: ingresos, color: SayoColors.green)),
                const SizedBox(width: 8),
                Expanded(child: _SummaryCard(label: 'Egresos', amount: egresos, color: SayoColors.red)),
                const SizedBox(width: 8),
                Expanded(child: _SummaryCard(label: 'Neto', amount: neto, color: neto >= 0 ? SayoColors.green : SayoColors.red)),
              ],
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: Row(
              children: [
                Text('${txns.length} movimientos', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
                const Spacer(),
                Text(_rangoLabel, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
              ],
            ),
          ),

          // List
          Expanded(
            child: txns.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: SayoColors.beige),
                        const SizedBox(height: 12),
                        Text('Sin resultados', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.grisMed)),
                        const SizedBox(height: 4),
                        Text('Intenta cambiar los filtros', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: txns.length,
                    itemBuilder: (ctx, i) {
                      final tx = txns[i];
                      // Date group header
                      final showHeader = i == 0 || !_isSameDay(txns[i - 1].date, tx.date);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader)
                            Padding(
                              padding: EdgeInsets.only(top: i == 0 ? 0 : 12, bottom: 8),
                              child: Text(
                                _dateGroupLabel(tx.date),
                                style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w700, color: SayoColors.grisMed),
                              ),
                            ),
                          GestureDetector(
                            onTap: () => _showTransactionDetail(tx),
                            child: _TransactionTile(tx: tx),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dateGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);

    if (day == today) return 'Hoy';
    if (day == today.subtract(const Duration(days: 1))) return 'Ayer';
    return DateFormat('EEEE d MMMM', 'es_MX').format(date);
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SayoColors.cafe,
              onPrimary: SayoColors.white,
              surface: SayoColors.cream,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  void _showDownloadSheet(List<Transaction> txns, double ingresos, double egresos) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: SayoColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Descargar movimientos', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
            const SizedBox(height: 4),
            Text('${txns.length} movimientos · $_rangoLabel', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisLight)),
            const SizedBox(height: 20),
            _DownloadOption(
              icon: Icons.picture_as_pdf_rounded,
              color: SayoColors.red,
              title: 'Descargar PDF',
              subtitle: 'Reporte con branding SAYO',
              onTap: () => _downloadPdf(txns),
            ),
            const SizedBox(height: 10),
            _DownloadOption(
              icon: Icons.table_chart_rounded,
              color: SayoColors.green,
              title: 'Descargar CSV',
              subtitle: 'Compatible con Excel',
              onTap: () => _downloadCsv(txns),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPdf(List<Transaction> txns) async {
    Navigator.pop(context);
    setState(() => _downloading = true);
    try {
      final bytes = await PdfService.generateMovimientosPdf(txns, rangoLabel: _rangoLabel);
      final now = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      downloadBytes(bytes, 'SAYO_Movimientos_$now.pdf', 'application/pdf');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF descargado', style: GoogleFonts.urbanist()),
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

  void _downloadCsv(List<Transaction> txns) {
    Navigator.pop(context);
    final csv = CsvService.generateMovimientosCsv(txns);
    final now = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    downloadString(csv, 'SAYO_Movimientos_$now.csv', 'text/csv');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV descargado', style: GoogleFonts.urbanist()),
        backgroundColor: SayoColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showTransactionDetail(Transaction tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: SayoColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: tx.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(tx.icon, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(height: 12),
            Text(tx.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
            const SizedBox(height: 4),
            Text(tx.subtitle, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
            const SizedBox(height: 16),
            Text(
              '${tx.isIncome ? '+' : '-'}${formatMoney(tx.amount)}',
              style: GoogleFonts.urbanist(fontSize: 32, fontWeight: FontWeight.w800, color: tx.isIncome ? SayoColors.green : SayoColors.gris),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
              child: Column(
                children: [
                  _DetailRow('Fecha', '${formatDate(tx.date)} ${formatTime(tx.date)}'),
                  const SizedBox(height: 8),
                  _DetailRow('Tipo', tx.isIncome ? 'Ingreso' : 'Cargo'),
                  const SizedBox(height: 8),
                  _DetailRow('Referencia', 'REF${tx.id.padLeft(8, '0')}'),
                  const SizedBox(height: 8),
                  _DetailRow('Estado', 'Completado'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: 'REF${tx.id.padLeft(8, '0')}'));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Referencia copiada', style: GoogleFonts.urbanist()),
                          backgroundColor: SayoColors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copiar ref'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Compartir'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets ───

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? SayoColors.cafe : SayoColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? SayoColors.cafe : SayoColors.beige, width: 0.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? SayoColors.white : SayoColors.grisMed),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryCard({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SayoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SayoColors.beige, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(amount),
              style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w800, color: color),
            ),
          ),
        ],
      ),
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
            width: 40, height: 40,
            decoration: BoxDecoration(color: tx.color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(tx.icon, style: const TextStyle(fontSize: 18))),
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
              Text(formatTime(tx.date), style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DownloadOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DownloadOption({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SayoColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: SayoColors.beige, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                  Text(subtitle, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                ],
              ),
            ),
            const Icon(Icons.download_rounded, size: 20, color: SayoColors.cafe),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
        Text(value, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
      ],
    );
  }
}
