import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';

// --- SPEI MOVEMENT MODEL ---

class SpeiMovement {
  final String id;
  final String clabe;
  final String name;
  final double amount;
  final String type; // entrada, salida
  final String status; // conciliado, pendiente, discrepancia
  final DateTime date;
  final String? reference;

  const SpeiMovement({required this.id, required this.clabe, required this.name, required this.amount, required this.type, required this.status, required this.date, this.reference});

  Color get statusColor {
    switch (status) {
      case 'conciliado': return SayoColors.green;
      case 'pendiente': return SayoColors.orange;
      case 'discrepancia': return SayoColors.red;
      default: return SayoColors.grisMed;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'conciliado': return 'Conciliado';
      case 'pendiente': return 'Pendiente';
      case 'discrepancia': return 'Discrepancia';
      default: return status;
    }
  }
}

final _today = DateTime(2026, 3, 4);

final mockSpeiMovements = <SpeiMovement>[
  SpeiMovement(id: 'SPEI001', clabe: '646180204800012345', name: 'José I. Benito', amount: 15000, type: 'entrada', status: 'conciliado', date: _today, reference: 'PAGO-NOMINA-001'),
  SpeiMovement(id: 'SPEI002', clabe: '012180015034567890', name: 'Carlos Mendoza', amount: 5000, type: 'salida', status: 'conciliado', date: _today, reference: 'TRF-OUT-002'),
  SpeiMovement(id: 'SPEI003', clabe: '646180204800023456', name: 'María García', amount: 80000, type: 'entrada', status: 'pendiente', date: _today, reference: 'DISP-CRD003'),
  SpeiMovement(id: 'SPEI004', clabe: '646180204800067890', name: 'Laura Díaz', amount: 9800, type: 'salida', status: 'discrepancia', date: _today, reference: 'PAGO-CRD005'),
  SpeiMovement(id: 'SPEI005', clabe: '646180204800089012', name: 'Patricia Vega', amount: 35000, type: 'entrada', status: 'conciliado', date: _today, reference: 'TRF-IN-005'),
  SpeiMovement(id: 'SPEI006', clabe: '014320001234567890', name: 'Empresa ABC', amount: 125000, type: 'entrada', status: 'pendiente', date: _today, reference: 'NOMINA-BATCH'),
  SpeiMovement(id: 'SPEI007', clabe: '646180204800034567', name: 'Carlos Mendoza', amount: 6200, type: 'salida', status: 'discrepancia', date: _today, reference: 'PAGO-MORA-004'),
  SpeiMovement(id: 'SPEI008', clabe: '646180204800045678', name: 'Ana S. Torres', amount: 50000, type: 'salida', status: 'conciliado', date: _today, reference: 'TRF-OUT-008'),
];

// --- SCREEN ---

class AdminConciliationScreen extends StatefulWidget {
  const AdminConciliationScreen({super.key});
  @override
  State<AdminConciliationScreen> createState() => _AdminConciliationScreenState();
}

class _AdminConciliationScreenState extends State<AdminConciliationScreen> {
  String _filter = 'todos';

  List<SpeiMovement> get _filtered {
    if (_filter == 'todos') return mockSpeiMovements;
    return mockSpeiMovements.where((m) => m.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final total = mockSpeiMovements.length;
    final conciliados = mockSpeiMovements.where((m) => m.status == 'conciliado').length;
    final pendientes = mockSpeiMovements.where((m) => m.status == 'pendiente').length;
    final discrepancias = mockSpeiMovements.where((m) => m.status == 'discrepancia').length;
    final totalEntradas = mockSpeiMovements.where((m) => m.type == 'entrada').fold(0.0, (s, m) => s + m.amount);
    final totalSalidas = mockSpeiMovements.where((m) => m.type == 'salida').fold(0.0, (s, m) => s + m.amount);

    return Scaffold(
      backgroundColor: SayoColors.cream,
      appBar: AppBar(
        backgroundColor: SayoColors.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris), onPressed: () => context.pop()),
        title: Text('Conciliacion SPEI', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('${_today.day}/${_today.month}/${_today.year}', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisLight))),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SayoColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SayoColors.beige, width: 0.5),
              ),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _FlowStat('Entradas', formatMoney(totalEntradas), SayoColors.green, Icons.arrow_downward_rounded),
                  Container(width: 1, height: 32, color: SayoColors.beige),
                  _FlowStat('Salidas', formatMoney(totalSalidas), SayoColors.red, Icons.arrow_upward_rounded),
                  Container(width: 1, height: 32, color: SayoColors.beige),
                  _FlowStat('Neto', formatMoney(totalEntradas - totalSalidas), totalEntradas >= totalSalidas ? SayoColors.green : SayoColors.red, Icons.swap_vert_rounded),
                ]),
                const SizedBox(height: 12),
                // Conciliation bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Row(children: [
                    Expanded(flex: conciliados, child: Container(height: 8, color: SayoColors.green)),
                    Expanded(flex: pendientes.clamp(1, 100), child: Container(height: 8, color: SayoColors.orange)),
                    Expanded(flex: discrepancias.clamp(1, 100), child: Container(height: 8, color: SayoColors.red)),
                  ]),
                ),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _Legend(SayoColors.green, 'Conciliados ($conciliados)'),
                  _Legend(SayoColors.orange, 'Pendientes ($pendientes)'),
                  _Legend(SayoColors.red, 'Discrepancias ($discrepancias)'),
                ]),
              ]),
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              _Chip('Todos', 'todos', _filter, SayoColors.cafe, (v) => setState(() => _filter = v)),
              const SizedBox(width: 6),
              _Chip('Pendientes', 'pendiente', _filter, SayoColors.orange, (v) => setState(() => _filter = v)),
              const SizedBox(width: 6),
              _Chip('Discrepancias', 'discrepancia', _filter, SayoColors.red, (v) => setState(() => _filter = v)),
              const SizedBox(width: 6),
              _Chip('OK', 'conciliado', _filter, SayoColors.green, (v) => setState(() => _filter = v)),
            ]),
          ),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(alignment: Alignment.centerLeft, child: Text('$total movimientos SPEI hoy', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisLight))),
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) => _SpeiCard(
                m: _filtered[i],
                onConciliate: () => _snack('${_filtered[i].id} conciliado manualmente', SayoColors.green),
                onAdjust: () => _showAdjust(_filtered[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdjust(SpeiMovement m) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: SayoColors.cream, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Ajustar discrepancia', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: SayoColors.gris)),
          const SizedBox(height: 4),
          Text('${m.id} · ${m.name}', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
            child: Column(children: [
              _InfoRow('Monto', formatMoney(m.amount)),
              const SizedBox(height: 6),
              _InfoRow('Tipo', m.type == 'entrada' ? 'Entrada SPEI' : 'Salida SPEI'),
              const SizedBox(height: 6),
              _InfoRow('CLABE', m.clabe),
              const SizedBox(height: 6),
              _InfoRow('Referencia', m.reference ?? 'N/A'),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () { Navigator.pop(context); _snack('Movimiento ${m.id} reversado', SayoColors.orange); },
              icon: const Icon(Icons.undo_rounded, size: 16),
              label: const Text('Reversar'),
            )),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton.icon(
              onPressed: () { Navigator.pop(context); _snack('Discrepancia ${m.id} ajustada', SayoColors.green); },
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('Ajustar'),
            )),
          ]),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _snack(String msg, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.urbanist()), backgroundColor: c, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }
}

// --- WIDGETS ---

class _FlowStat extends StatelessWidget {
  final String label, value; final Color color; final IconData icon;
  const _FlowStat(this.label, this.value, this.color, this.icon);
  @override Widget build(BuildContext context) => Column(children: [
    Icon(icon, size: 14, color: color),
    Text(value, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
    Text(label, style: GoogleFonts.urbanist(fontSize: 9, color: SayoColors.grisLight)),
  ]);
}

class _Legend extends StatelessWidget {
  final Color color; final String label;
  const _Legend(this.color, this.label);
  @override Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(label, style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisMed)),
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

class _SpeiCard extends StatelessWidget {
  final SpeiMovement m; final VoidCallback onConciliate, onAdjust;
  const _SpeiCard({required this.m, required this.onConciliate, required this.onAdjust});
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: m.statusColor.withValues(alpha: 0.3), width: 0.5)),
    child: Column(children: [
      Row(children: [
        Icon(m.type == 'entrada' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, size: 16, color: m.type == 'entrada' ? SayoColors.green : SayoColors.red),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m.name, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.gris)),
          Text('${m.id} · ${m.reference ?? ''}', style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${m.type == 'entrada' ? '+' : '-'}${formatMoney(m.amount)}', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: m.type == 'entrada' ? SayoColors.green : SayoColors.gris)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: m.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(m.statusLabel, style: GoogleFonts.urbanist(fontSize: 9, fontWeight: FontWeight.w600, color: m.statusColor))),
        ]),
      ]),
      if (m.status != 'conciliado') ...[
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          if (m.status == 'pendiente') TextButton(onPressed: onConciliate, child: Text('Conciliar', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: SayoColors.green))),
          if (m.status == 'discrepancia') TextButton(onPressed: onAdjust, child: Text('Ajustar', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: SayoColors.red))),
        ]),
      ],
    ]),
  );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);
  @override Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
    Text(value, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
  ]);
}
