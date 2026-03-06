import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/data/mock_data.dart';

class AdminUserMovementsScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const AdminUserMovementsScreen({super.key, required this.userId, required this.userName});

  @override
  State<AdminUserMovementsScreen> createState() => _AdminUserMovementsScreenState();
}

class _AdminUserMovementsScreenState extends State<AdminUserMovementsScreen> {
  int _typeFilter = 0; // 0=Todos, 1=Ingresos, 2=Egresos

  List<Transaction> get _filtered {
    // Use extended transactions (simulating user-specific data)
    var list = List<Transaction>.from(mockTransactionsExtended);

    if (_typeFilter == 1) {
      list = list.where((t) => t.isIncome).toList();
    } else if (_typeFilter == 2) {
      list = list.where((t) => !t.isIncome).toList();
    }

    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _filtered;
    final totalIncome = transactions.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final totalExpense = transactions.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);

    return Scaffold(
      backgroundColor: SayoColors.cream,
      appBar: AppBar(
        backgroundColor: SayoColors.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Movimientos', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: SayoColors.gris)),
            Text(widget.userName, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                Expanded(child: _SummaryBox('Ingresos', formatMoney(totalIncome), SayoColors.green)),
                const SizedBox(width: 8),
                Expanded(child: _SummaryBox('Egresos', formatMoney(totalExpense), SayoColors.red)),
                const SizedBox(width: 8),
                Expanded(child: _SummaryBox('Neto', formatMoney(totalIncome - totalExpense), totalIncome >= totalExpense ? SayoColors.green : SayoColors.red)),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _FilterChip('Todos', 0, _typeFilter, () => setState(() => _typeFilter = 0)),
                const SizedBox(width: 8),
                _FilterChip('Ingresos', 1, _typeFilter, () => setState(() => _typeFilter = 1)),
                const SizedBox(width: 8),
                _FilterChip('Egresos', 2, _typeFilter, () => setState(() => _typeFilter = 2)),
                const Spacer(),
                Text('${transactions.length} mov.', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisLight)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Transaction list
          Expanded(
            child: transactions.isEmpty
                ? Center(child: Text('Sin movimientos', style: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.grisLight)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: transactions.length,
                    itemBuilder: (ctx, i) {
                      final tx = transactions[i];
                      final showDateHeader = i == 0 || !_sameDay(tx.date, transactions[i - 1].date);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateHeader)
                            Padding(
                              padding: EdgeInsets.only(top: i == 0 ? 0 : 12, bottom: 8),
                              child: Text(_dateLabel(tx.date), style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
                            ),
                          GestureDetector(
                            onTap: () => _showDetail(context, tx),
                            child: _TxTile(tx: tx),
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

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    if (_sameDay(d, now)) return 'Hoy';
    if (_sameDay(d, now.subtract(const Duration(days: 1)))) return 'Ayer';
    const months = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${d.day} de ${months[d.month]} ${d.year}';
  }

  void _showDetail(BuildContext context, Transaction tx) {
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
                  _DetailRow('Fecha', formatDate(tx.date)),
                  const SizedBox(height: 8),
                  _DetailRow('Tipo', tx.isIncome ? 'Ingreso' : 'Cargo'),
                  const SizedBox(height: 8),
                  _DetailRow('Referencia', 'REF${tx.id.padLeft(8, '0')}'),
                  const SizedBox(height: 8),
                  _DetailRow('Usuario', widget.userName),
                  const SizedBox(height: 8),
                  _DetailRow('ID Usuario', widget.userId),
                  const SizedBox(height: 8),
                  _DetailRow('Estado', 'Completado'),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS ---

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryBox(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SayoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SayoColors.beige, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int value;
  final int selected;
  final VoidCallback onTap;
  const _FilterChip(this.label, this.value, this.selected, this.onTap);
  @override
  Widget build(BuildContext context) {
    final isActive = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? SayoColors.cafe.withValues(alpha: 0.1) : SayoColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? SayoColors.cafe : SayoColors.beige, width: isActive ? 1.5 : 0.5),
        ),
        child: Text(label, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? SayoColors.cafe : SayoColors.grisMed)),
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final Transaction tx;
  const _TxTile({required this.tx});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SayoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SayoColors.beige.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: tx.color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(tx.icon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tx.title, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.gris)),
              Text(tx.subtitle, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisLight)),
            ],
          )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${tx.isIncome ? '+' : '-'}${formatMoney(tx.amount)}', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: tx.isIncome ? SayoColors.green : SayoColors.gris)),
              Text(timeAgo(tx.date), style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
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
