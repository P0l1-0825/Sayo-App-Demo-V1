import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import 'admin_mock_data.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SayoColors.cream,
      appBar: AppBar(
        backgroundColor: SayoColors.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris),
          onPressed: () => context.pop(),
        ),
        title: Text('Reportes y Analiticas', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio overview
            Text('Portafolio', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            const SizedBox(height: 10),
            _MetricCard(
              title: 'Resumen del portafolio',
              icon: Icons.pie_chart_rounded,
              color: SayoColors.blue,
              metrics: [
                _Metric('Credito total asignado', formatMoney(AdminSummary.totalCreditAssigned)),
                _Metric('Credito colocado', formatMoney(AdminSummary.totalCreditUsed)),
                _Metric('Credito disponible', formatMoney(AdminSummary.totalCreditAvailable)),
                _Metric('Tasa de colocacion', '${(AdminSummary.totalCreditUsed / AdminSummary.totalCreditAssigned * 100).toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 10),

            // Revenue
            _MetricCard(
              title: 'Ingresos y cobranza',
              icon: Icons.trending_up_rounded,
              color: SayoColors.green,
              metrics: [
                _Metric('Cobranza mensual esperada', formatMoney(AdminSummary.monthlyRevenue)),
                _Metric('Ingresos anuales estimados', formatMoney(AdminSummary.monthlyRevenue * 12)),
                _Metric('Saldo total en wallets', formatMoney(AdminSummary.totalBalance)),
              ],
            ),
            const SizedBox(height: 10),

            // Risk
            _MetricCard(
              title: 'Riesgo y morosidad',
              icon: Icons.warning_rounded,
              color: SayoColors.red,
              metrics: [
                _Metric('Cartera en riesgo', formatMoney(AdminSummary.atRiskAmount)),
                _Metric('% cartera en riesgo', '${(AdminSummary.atRiskAmount / AdminSummary.totalCreditUsed * 100).toStringAsFixed(1)}%'),
                _Metric('Creditos en mora', '${mockCreditAssignments.where((c) => c.status == 'en_mora').length}'),
                _Metric('Creditos vencidos', '${mockCreditAssignments.where((c) => c.status == 'vencido').length}'),
              ],
            ),
            const SizedBox(height: 20),

            // Users
            Text('Usuarios', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            const SizedBox(height: 10),
            _MetricCard(
              title: 'Base de usuarios',
              icon: Icons.people_rounded,
              color: SayoColors.cafe,
              metrics: [
                _Metric('Total usuarios', '${AdminSummary.totalUsers}'),
                _Metric('Activos', '${AdminSummary.activeUsers}'),
                _Metric('Pendientes KYC', '${AdminSummary.pendingUsers}'),
                _Metric('Suspendidos', '${AdminSummary.suspendedUsers}'),
                _Metric('Tasa de activacion', '${(AdminSummary.activeUsers / AdminSummary.totalUsers * 100).toStringAsFixed(0)}%'),
              ],
            ),
            const SizedBox(height: 10),

            // Credit distribution chart (visual bar chart)
            Text('Distribucion por producto', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            const SizedBox(height: 10),
            _ProductDistributionCard(),
            const SizedBox(height: 20),

            // Top users by credit
            Text('Top usuarios por credito', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            const SizedBox(height: 10),
            ..._topCreditUsers().map((entry) => _TopUserRow(
              rank: entry.key,
              name: entry.value['name'] as String,
              amount: entry.value['amount'] as double,
              product: entry.value['product'] as String,
              color: entry.value['color'] as Color,
            )),
            const SizedBox(height: 20),

            // KPIs
            Text('KPIs operativos', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _KPIBox('Ticket promedio', formatMoney(AdminSummary.totalCreditUsed / mockCreditAssignments.where((c) => c.status != 'liquidado').length), SayoColors.blue)),
                const SizedBox(width: 10),
                Expanded(child: _KPIBox('Tasa promedio', '${_avgRate()}% anual', SayoColors.green)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _KPIBox('Plazo promedio', '${_avgPlazo()} meses', SayoColors.orange)),
                const SizedBox(width: 10),
                Expanded(child: _KPIBox('Tasa de mora', '${_delinquencyRate()}%', SayoColors.red)),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  List<MapEntry<int, Map<String, dynamic>>> _topCreditUsers() {
    final active = mockCreditAssignments.where((c) => c.status != 'liquidado').toList()
      ..sort((a, b) => b.usedAmount.compareTo(a.usedAmount));
    return active.take(5).toList().asMap().entries.map((e) => MapEntry(
      e.key + 1,
      {'name': e.value.userName, 'amount': e.value.usedAmount, 'product': e.value.productLabel, 'color': e.value.productColor},
    )).toList();
  }

  String _avgRate() {
    final active = mockCreditAssignments.where((c) => c.status != 'liquidado').toList();
    if (active.isEmpty) return '0';
    final avg = active.fold(0.0, (sum, c) => sum + c.interestRate) / active.length;
    return (avg * 100).toStringAsFixed(1);
  }

  int _avgPlazo() {
    final active = mockCreditAssignments.where((c) => c.status != 'liquidado').toList();
    if (active.isEmpty) return 0;
    return (active.fold(0, (sum, c) => sum + c.plazoMonths) / active.length).round();
  }

  String _delinquencyRate() {
    final total = mockCreditAssignments.where((c) => c.status != 'liquidado').length;
    final delinquent = mockCreditAssignments.where((c) => c.status == 'en_mora' || c.status == 'vencido').length;
    if (total == 0) return '0';
    return (delinquent / total * 100).toStringAsFixed(1);
  }
}

// --- WIDGETS ---

class _Metric {
  final String label;
  final String value;
  const _Metric(this.label, this.value);
}

class _MetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<_Metric> metrics;

  const _MetricCard({required this.title, required this.icon, required this.color, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SayoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SayoColors.beige, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            ],
          ),
          const SizedBox(height: 14),
          ...metrics.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(m.label, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
                Text(m.value, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.gris)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _ProductDistributionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final products = <String, _ProductData>{};
    for (final c in mockCreditAssignments.where((c) => c.status != 'liquidado')) {
      products.putIfAbsent(c.productType, () => _ProductData(c.productLabel, c.productColor, 0, 0));
      final p = products[c.productType]!;
      products[c.productType] = _ProductData(p.label, p.color, p.count + 1, p.amount + c.usedAmount);
    }

    final total = products.values.fold(0.0, (s, p) => s + p.amount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SayoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SayoColors.beige, width: 0.5),
      ),
      child: Column(
        children: products.entries.map((e) {
          final pct = total > 0 ? e.value.amount / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: e.value.color, borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 8),
                      Text(e.value.label, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
                    ]),
                    Text('${formatMoney(e.value.amount)} (${(pct * 100).toStringAsFixed(0)}%)', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: SayoColors.beige.withValues(alpha: 0.5),
                    valueColor: AlwaysStoppedAnimation(e.value.color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProductData {
  final String label;
  final Color color;
  final int count;
  final double amount;
  const _ProductData(this.label, this.color, this.count, this.amount);
}

class _TopUserRow extends StatelessWidget {
  final int rank;
  final String name;
  final double amount;
  final String product;
  final Color color;

  const _TopUserRow({required this.rank, required this.name, required this.amount, required this.product, required this.color});

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
            width: 28, height: 28,
            decoration: BoxDecoration(color: SayoColors.beige.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text('$rank', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w700, color: SayoColors.grisMed))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
              Text(product, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
            ],
          )),
          Text(formatMoney(amount), style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _KPIBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _KPIBox(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SayoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SayoColors.beige, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}
