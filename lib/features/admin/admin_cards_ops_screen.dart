import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';

// --- CARD OPS MODEL ---

class AdminCard {
  final String id;
  final String userId;
  final String userName;
  final String type; // virtual, fisica
  final String last4;
  final String status; // activa, bloqueada, pendiente_emision, reportada
  final DateTime issuedAt;
  final double monthlySpend;

  const AdminCard({required this.id, required this.userId, required this.userName, required this.type, required this.last4, required this.status, required this.issuedAt, required this.monthlySpend});

  Color get statusColor {
    switch (status) {
      case 'activa': return SayoColors.green;
      case 'bloqueada': return SayoColors.red;
      case 'pendiente_emision': return SayoColors.orange;
      case 'reportada': return SayoColors.red;
      default: return SayoColors.grisMed;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'activa': return 'Activa';
      case 'bloqueada': return 'Bloqueada';
      case 'pendiente_emision': return 'Pend. emision';
      case 'reportada': return 'Reportada';
      default: return status;
    }
  }

  IconData get typeIcon => type == 'virtual' ? Icons.credit_card_rounded : Icons.card_membership_rounded;
}

final mockAdminCards = <AdminCard>[
  AdminCard(id: 'CRD_V001', userId: 'USR001', userName: 'José Ignacio Benito', type: 'virtual', last4: '4532', status: 'activa', issuedAt: DateTime(2025, 6, 15), monthlySpend: 12500),
  AdminCard(id: 'CRD_F001', userId: 'USR001', userName: 'José Ignacio Benito', type: 'fisica', last4: '8891', status: 'activa', issuedAt: DateTime(2025, 8, 1), monthlySpend: 8200),
  AdminCard(id: 'CRD_V002', userId: 'USR002', userName: 'María García López', type: 'virtual', last4: '7723', status: 'activa', issuedAt: DateTime(2025, 5, 10), monthlySpend: 35400),
  AdminCard(id: 'CRD_F002', userId: 'USR003', userName: 'Carlos Mendoza Ruiz', type: 'fisica', last4: '1156', status: 'bloqueada', issuedAt: DateTime(2025, 10, 5), monthlySpend: 0),
  AdminCard(id: 'CRD_V003', userId: 'USR008', userName: 'Patricia Vega Sánchez', type: 'virtual', last4: '9078', status: 'activa', issuedAt: DateTime(2025, 12, 20), monthlySpend: 15600),
  AdminCard(id: 'CRD_F003', userId: 'USR006', userName: 'Laura Díaz Moreno', type: 'fisica', last4: '3345', status: 'reportada', issuedAt: DateTime(2025, 9, 12), monthlySpend: 0),
  AdminCard(id: 'CRD_V004', userId: 'USR004', userName: 'Ana Sofía Torres', type: 'virtual', last4: '6612', status: 'pendiente_emision', issuedAt: DateTime(2026, 3, 1), monthlySpend: 0),
];

// --- FRAUD ALERT ---

class FraudAlert {
  final String cardId;
  final String userName;
  final String description;
  final double amount;
  final String severity; // alto, medio, bajo
  final DateTime detectedAt;

  const FraudAlert({required this.cardId, required this.userName, required this.description, required this.amount, required this.severity, required this.detectedAt});

  Color get severityColor {
    switch (severity) {
      case 'alto': return SayoColors.red;
      case 'medio': return SayoColors.orange;
      default: return SayoColors.blue;
    }
  }
}

final mockFraudAlerts = <FraudAlert>[
  FraudAlert(cardId: 'CRD_F003', userName: 'Laura Díaz Moreno', description: 'Intento de compra en pais no autorizado (Nigeria)', amount: 45000, severity: 'alto', detectedAt: DateTime(2026, 3, 3, 22, 15)),
  FraudAlert(cardId: 'CRD_V002', userName: 'María García López', description: 'Multiples transacciones rapidas en comercios diferentes', amount: 12300, severity: 'medio', detectedAt: DateTime(2026, 3, 4, 6, 45)),
  FraudAlert(cardId: 'CRD_F001', userName: 'José Ignacio Benito', description: 'Compra superior al patron habitual', amount: 28500, severity: 'bajo', detectedAt: DateTime(2026, 3, 4, 10, 30)),
];

// --- SCREEN ---

class AdminCardsOpsScreen extends StatefulWidget {
  const AdminCardsOpsScreen({super.key});
  @override
  State<AdminCardsOpsScreen> createState() => _AdminCardsOpsScreenState();
}

class _AdminCardsOpsScreenState extends State<AdminCardsOpsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final active = mockAdminCards.where((c) => c.status == 'activa').length;
    final blocked = mockAdminCards.where((c) => c.status == 'bloqueada' || c.status == 'reportada').length;

    return Scaffold(
      backgroundColor: SayoColors.cream,
      appBar: AppBar(
        backgroundColor: SayoColors.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris), onPressed: () => context.pop()),
        title: Text('Tarjetas Ops', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
      ),
      body: Column(
        children: [
          // Summary
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(children: [
              Expanded(child: _SumBox('Total', '${mockAdminCards.length}', SayoColors.cafe)),
              const SizedBox(width: 8),
              Expanded(child: _SumBox('Activas', '$active', SayoColors.green)),
              const SizedBox(width: 8),
              Expanded(child: _SumBox('Bloqueadas', '$blocked', SayoColors.red)),
              const SizedBox(width: 8),
              Expanded(child: _SumBox('Alertas', '${mockFraudAlerts.length}', SayoColors.orange)),
            ]),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              _TabBtn('Tarjetas', 0, _tab, () => setState(() => _tab = 0)),
              const SizedBox(width: 8),
              _TabBtn('Fraude', 1, _tab, () => setState(() => _tab = 1)),
              const SizedBox(width: 8),
              _TabBtn('Emision', 2, _tab, () => setState(() => _tab = 2)),
            ]),
          ),
          const SizedBox(height: 12),

          Expanded(child: _tab == 0 ? _cardsList() : _tab == 1 ? _fraudList() : _emissionList()),
        ],
      ),
    );
  }

  Widget _cardsList() => ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    itemCount: mockAdminCards.length,
    itemBuilder: (ctx, i) {
      final c = mockAdminCards[i];
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: c.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(c.typeIcon, color: c.statusColor, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.userName, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            Text('${c.type == 'virtual' ? 'Virtual' : 'Fisica'} •••• ${c.last4}', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: c.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(c.statusLabel, style: GoogleFonts.urbanist(fontSize: 9, fontWeight: FontWeight.w600, color: c.statusColor))),
            const SizedBox(height: 4),
            if (c.status == 'activa') GestureDetector(
              onTap: () => _blockCard(c),
              child: Text('Bloquear', style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w600, color: SayoColors.red)),
            ),
            if (c.status == 'bloqueada') GestureDetector(
              onTap: () => _snack('Tarjeta ${c.last4} desbloqueada', SayoColors.green),
              child: Text('Desbloquear', style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w600, color: SayoColors.green)),
            ),
          ]),
        ]),
      );
    },
  );

  Widget _fraudList() => ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    itemCount: mockFraudAlerts.length,
    itemBuilder: (ctx, i) {
      final a = mockFraudAlerts[i];
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: a.severityColor.withValues(alpha: 0.3), width: 0.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: a.severityColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.shield_rounded, color: a.severityColor, size: 16)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.userName, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.gris)),
              Text('Tarjeta ${a.cardId}', style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: a.severityColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(a.severity.toUpperCase(), style: GoogleFonts.urbanist(fontSize: 9, fontWeight: FontWeight.w700, color: a.severityColor))),
          ]),
          const SizedBox(height: 8),
          Text(a.description, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('\$${a.amount.toStringAsFixed(0)}', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: a.severityColor)),
            Row(children: [
              OutlinedButton(onPressed: () => _snack('Alerta descartada', SayoColors.grisMed), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)), child: Text('Descartar', style: GoogleFonts.urbanist(fontSize: 11))),
              const SizedBox(width: 6),
              ElevatedButton(onPressed: () => _snack('Tarjeta bloqueada por fraude', SayoColors.red), style: ElevatedButton.styleFrom(backgroundColor: SayoColors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)), child: Text('Bloquear', style: GoogleFonts.urbanist(fontSize: 11))),
            ]),
          ]),
        ]),
      );
    },
  );

  Widget _emissionList() {
    final pending = mockAdminCards.where((c) => c.status == 'pendiente_emision').toList();
    if (pending.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.check_circle_rounded, size: 48, color: SayoColors.green.withValues(alpha: 0.5)),
      const SizedBox(height: 12),
      Text('Sin emisiones pendientes', style: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.grisLight)),
    ]));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: pending.length,
      itemBuilder: (ctx, i) {
        final c = pending[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.orange.withValues(alpha: 0.3), width: 0.5)),
          child: Column(children: [
            Row(children: [
              Icon(c.typeIcon, color: SayoColors.orange, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.userName, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                Text('${c.type == 'virtual' ? 'Virtual' : 'Fisica'} · Solicitada ${c.issuedAt.day}/${c.issuedAt.month}/${c.issuedAt.year}', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
              ])),
            ]),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () => _snack('Tarjeta ${c.type} emitida para ${c.userName}', SayoColors.green),
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('Emitir tarjeta'),
            )),
          ]),
        );
      },
    );
  }

  void _blockCard(AdminCard c) {
    _snack('Tarjeta •••• ${c.last4} bloqueada', SayoColors.red);
  }

  void _snack(String msg, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.urbanist()), backgroundColor: c, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }
}

// --- WIDGETS ---

class _SumBox extends StatelessWidget {
  final String label, value; final Color color;
  const _SumBox(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: SayoColors.beige, width: 0.5)),
    child: Column(children: [
      Text(value, style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: GoogleFonts.urbanist(fontSize: 9, color: SayoColors.grisLight)),
    ]),
  );
}

class _TabBtn extends StatelessWidget {
  final String label; final int index, current; final VoidCallback onTap;
  const _TabBtn(this.label, this.index, this.current, this.onTap);
  @override Widget build(BuildContext context) {
    final a = index == current;
    return Expanded(child: GestureDetector(onTap: onTap, child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: a ? SayoColors.cafe.withValues(alpha: 0.1) : SayoColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: a ? SayoColors.cafe : SayoColors.beige, width: a ? 1.5 : 0.5)),
      child: Center(child: Text(label, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: a ? FontWeight.w700 : FontWeight.w500, color: a ? SayoColors.cafe : SayoColors.grisMed))),
    )));
  }
}
