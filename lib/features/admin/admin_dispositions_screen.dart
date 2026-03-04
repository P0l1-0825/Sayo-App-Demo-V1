import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import 'admin_mock_data.dart';

// --- DISPOSITION MODEL ---

class CreditDisposition {
  final String id;
  final String userId;
  final String userName;
  final String creditId;
  final String productType;
  final double amount;
  final String status; // pendiente, aprobada, rechazada, en_revision
  final DateTime requestedAt;
  final String? fundOrigin;
  final String? purpose;

  const CreditDisposition({required this.id, required this.userId, required this.userName, required this.creditId, required this.productType, required this.amount, required this.status, required this.requestedAt, this.fundOrigin, this.purpose});

  Color get statusColor {
    switch (status) {
      case 'pendiente': return SayoColors.orange;
      case 'aprobada': return SayoColors.green;
      case 'rechazada': return SayoColors.red;
      case 'en_revision': return SayoColors.blue;
      default: return SayoColors.grisMed;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pendiente': return 'Pendiente';
      case 'aprobada': return 'Aprobada';
      case 'rechazada': return 'Rechazada';
      case 'en_revision': return 'En revision';
      default: return status;
    }
  }
}

final mockDispositions = <CreditDisposition>[
  CreditDisposition(id: 'DIS001', userId: 'USR001', userName: 'José Ignacio Benito', creditId: 'CRD001', productType: 'nomina', amount: 25000, status: 'pendiente', requestedAt: DateTime(2026, 3, 4, 9, 30), fundOrigin: 'Linea de credito nomina', purpose: 'Capital de trabajo'),
  CreditDisposition(id: 'DIS002', userId: 'USR002', userName: 'María García López', creditId: 'CRD003', productType: 'simple', amount: 80000, status: 'en_revision', requestedAt: DateTime(2026, 3, 3, 14, 15), fundOrigin: 'Credito simple', purpose: 'Compra de equipo'),
  CreditDisposition(id: 'DIS003', userId: 'USR008', userName: 'Patricia Vega Sánchez', creditId: 'CRD007', productType: 'nomina', amount: 35000, status: 'pendiente', requestedAt: DateTime(2026, 3, 4, 11, 45), fundOrigin: 'Linea de credito nomina', purpose: 'Consolidacion de deudas'),
  CreditDisposition(id: 'DIS004', userId: 'USR004', userName: 'Ana Sofía Torres', creditId: 'CRD008', productType: 'adelanto', amount: 12000, status: 'aprobada', requestedAt: DateTime(2026, 3, 2, 8, 0), fundOrigin: 'Adelanto nomina', purpose: 'Gastos personales'),
  CreditDisposition(id: 'DIS005', userId: 'USR006', userName: 'Laura Díaz Moreno', creditId: 'CRD005', productType: 'revolvente', amount: 5000, status: 'rechazada', requestedAt: DateTime(2026, 3, 1, 16, 30), fundOrigin: 'Revolvente', purpose: 'Compras', ),
];

// --- SCREEN ---

class AdminDispositionsScreen extends StatefulWidget {
  const AdminDispositionsScreen({super.key});
  @override
  State<AdminDispositionsScreen> createState() => _AdminDispositionsScreenState();
}

class _AdminDispositionsScreenState extends State<AdminDispositionsScreen> {
  String _filter = 'pendiente';

  List<CreditDisposition> get _filtered {
    if (_filter == 'todos') return mockDispositions;
    return mockDispositions.where((d) => d.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pending = mockDispositions.where((d) => d.status == 'pendiente' || d.status == 'en_revision').length;
    final totalPending = mockDispositions.where((d) => d.status == 'pendiente' || d.status == 'en_revision').fold(0.0, (s, d) => s + d.amount);

    return Scaffold(
      backgroundColor: SayoColors.cream,
      appBar: AppBar(
        backgroundColor: SayoColors.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris), onPressed: () => context.pop()),
        title: Text('Disposiciones', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
        actions: [
          if (pending > 0) Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: SayoColors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Text('$pending por autorizar', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.orange)),
            )),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat('Pendientes', '$pending', SayoColors.orange),
                  Container(width: 1, height: 28, color: SayoColors.beige),
                  _Stat('Monto', formatMoney(totalPending), SayoColors.cafe),
                  Container(width: 1, height: 28, color: SayoColors.beige),
                  _Stat('Aprobadas hoy', '${mockDispositions.where((d) => d.status == 'aprobada').length}', SayoColors.green),
                ],
              ),
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _Chip('Pendientes', 'pendiente', _filter, SayoColors.orange, (v) => setState(() => _filter = v)),
                const SizedBox(width: 6),
                _Chip('En revision', 'en_revision', _filter, SayoColors.blue, (v) => setState(() => _filter = v)),
                const SizedBox(width: 6),
                _Chip('Aprobadas', 'aprobada', _filter, SayoColors.green, (v) => setState(() => _filter = v)),
                const SizedBox(width: 6),
                _Chip('Todos', 'todos', _filter, SayoColors.cafe, (v) => setState(() => _filter = v)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // List
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text('Sin disposiciones', style: GoogleFonts.urbanist(color: SayoColors.grisLight)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) => _DispositionCard(
                      d: _filtered[i],
                      onApprove: () => _approve(_filtered[i]),
                      onReject: () => _reject(_filtered[i]),
                      onReview: () => _review(_filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _approve(CreditDisposition d) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: SayoColors.cream,
        title: Text('Aprobar disposicion', style: GoogleFonts.urbanist(fontWeight: FontWeight.w800, color: SayoColors.gris)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${d.userName} solicita:', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
          const SizedBox(height: 8),
          Text(formatMoney(d.amount), style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.w800, color: SayoColors.green)),
          const SizedBox(height: 4),
          Text('Origen: ${d.fundOrigin ?? "N/A"}', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisLight)),
          Text('Destino: ${d.purpose ?? "N/A"}', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisLight)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: SayoColors.green.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, size: 16, color: SayoColors.green),
              const SizedBox(width: 8),
              Expanded(child: Text('Los fondos se depositaran via SPEI a la CLABE del usuario.', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.green))),
            ]),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar', style: GoogleFonts.urbanist(color: SayoColors.grisMed))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _snack('Disposicion ${d.id} aprobada por ${formatMoney(d.amount)}', SayoColors.green);
            },
            child: const Text('Aprobar'),
          ),
        ],
      ),
    );
  }

  void _reject(CreditDisposition d) {
    final reasons = ['Limite excedido', 'Documentacion incompleta', 'Score insuficiente', 'Actividad sospechosa', 'Solicitud del supervisor'];
    String? selected;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: SayoColors.cream, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Rechazar disposicion', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: SayoColors.gris)),
            Text('${d.userName} · ${formatMoney(d.amount)}', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
            const SizedBox(height: 12),
            ...reasons.map((r) => GestureDetector(
              onTap: () => setModalState(() => selected = r),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected == r ? SayoColors.red.withValues(alpha: 0.06) : SayoColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: selected == r ? SayoColors.red : SayoColors.beige, width: selected == r ? 1.5 : 0.5),
                ),
                child: Row(children: [
                  Icon(selected == r ? Icons.radio_button_checked : Icons.radio_button_off, size: 16, color: selected == r ? SayoColors.red : SayoColors.grisLight),
                  const SizedBox(width: 10),
                  Text(r, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.gris)),
                ]),
              ),
            )),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: selected == null ? null : () { Navigator.pop(ctx); _snack('Disposicion rechazada: $selected', SayoColors.red); },
              style: ElevatedButton.styleFrom(backgroundColor: SayoColors.red, foregroundColor: Colors.white),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Rechazar'),
            )),
          ]),
        ),
      ),
    );
  }

  void _review(CreditDisposition d) {
    _snack('${d.id} marcada en revision', SayoColors.blue);
  }

  void _snack(String msg, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.urbanist()), backgroundColor: c, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }
}

// --- WIDGETS ---

class _Stat extends StatelessWidget {
  final String label, value; final Color color;
  const _Stat(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Column(children: [
    Text(value, style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
    Text(label, style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
  ]);
}

class _Chip extends StatelessWidget {
  final String label, value, selected; final Color color; final ValueChanged<String> onTap;
  const _Chip(this.label, this.value, this.selected, this.color, this.onTap);
  @override Widget build(BuildContext context) {
    final a = value == selected;
    return GestureDetector(onTap: () => onTap(value), child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: a ? color.withValues(alpha: 0.1) : SayoColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: a ? color : SayoColors.beige, width: a ? 1.5 : 0.5)),
      child: Text(label, style: GoogleFonts.urbanist(fontSize: 11, fontWeight: a ? FontWeight.w700 : FontWeight.w500, color: a ? color : SayoColors.grisMed)),
    ));
  }
}

class _DispositionCard extends StatelessWidget {
  final CreditDisposition d; final VoidCallback onApprove, onReject, onReview;
  const _DispositionCard({required this.d, required this.onApprove, required this.onReject, required this.onReview});
  @override Widget build(BuildContext context) {
    final credit = mockCreditAssignments.where((c) => c.id == d.creditId).isNotEmpty ? mockCreditAssignments.firstWhere((c) => c.id == d.creditId) : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: d.statusColor.withValues(alpha: 0.3), width: 0.5)),
      child: Column(children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: d.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(credit?.productIcon ?? Icons.payments_rounded, color: d.statusColor, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d.userName, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            Text('${d.id} · ${d.purpose ?? d.productType}', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(formatMoney(d.amount), style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w800, color: d.statusColor)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: d.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(d.statusLabel, style: GoogleFonts.urbanist(fontSize: 9, fontWeight: FontWeight.w700, color: d.statusColor))),
          ]),
        ]),
        if (d.status == 'pendiente' || d.status == 'en_revision') ...[
          const SizedBox(height: 10),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: SayoColors.cream, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Text('Origen: ', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
              Text(d.fundOrigin ?? 'N/A', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: SayoColors.gris)),
              const Spacer(),
              Text('${d.requestedAt.hour}:${d.requestedAt.minute.toString().padLeft(2, '0')}', style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
            ]),
          ),
          const SizedBox(height: 8),
          Row(children: [
            if (d.status == 'pendiente') Expanded(child: OutlinedButton(onPressed: onReview, child: Text('Revisar', style: GoogleFonts.urbanist(fontSize: 12)))),
            if (d.status == 'pendiente') const SizedBox(width: 6),
            Expanded(child: OutlinedButton(onPressed: onReject, style: OutlinedButton.styleFrom(side: const BorderSide(color: SayoColors.red), foregroundColor: SayoColors.red), child: Text('Rechazar', style: GoogleFonts.urbanist(fontSize: 12)))),
            const SizedBox(width: 6),
            Expanded(child: ElevatedButton(onPressed: onApprove, child: Text('Aprobar', style: GoogleFonts.urbanist(fontSize: 12)))),
          ]),
        ],
      ]),
    );
  }
}
