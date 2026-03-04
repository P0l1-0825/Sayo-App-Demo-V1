import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import 'admin_mock_data.dart';

class AdminCollectionsScreen extends StatefulWidget {
  const AdminCollectionsScreen({super.key});

  @override
  State<AdminCollectionsScreen> createState() => _AdminCollectionsScreenState();
}

class _AdminCollectionsScreenState extends State<AdminCollectionsScreen> {
  int _tabIndex = 0; // 0=Morosidad, 1=Planes de pago

  List<CreditAssignment> get _delinquent => mockCreditAssignments
      .where((c) => c.status == 'en_mora' || c.status == 'vencido')
      .toList()
    ..sort((a, b) => b.usedAmount.compareTo(a.usedAmount));

  @override
  Widget build(BuildContext context) {
    final totalAtRisk = _delinquent.fold(0.0, (sum, c) => sum + c.usedAmount);
    final totalMonthly = _delinquent.fold(0.0, (sum, c) => sum + c.monthlyPayment);

    return Scaffold(
      backgroundColor: SayoColors.cream,
      appBar: AppBar(
        backgroundColor: SayoColors.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris),
          onPressed: () => context.pop(),
        ),
        title: Text('Cobranza', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
      ),
      body: Column(
        children: [
          // Summary
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SayoColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SayoColors.red.withValues(alpha: 0.2), width: 0.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SummaryItem('Cartera en riesgo', formatMoney(totalAtRisk), SayoColors.red),
                      Container(width: 1, height: 36, color: SayoColors.beige),
                      _SummaryItem('Cobranza pendiente', formatMoney(totalMonthly), SayoColors.orange),
                      Container(width: 1, height: 36, color: SayoColors.beige),
                      _SummaryItem('Cuentas', '${_delinquent.length}', SayoColors.gris),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Aging bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: _delinquent.where((c) => c.status == 'en_mora').length,
                          child: Container(height: 6, color: SayoColors.orange),
                        ),
                        Expanded(
                          flex: _delinquent.where((c) => c.status == 'vencido').length.clamp(1, 100),
                          child: Container(height: 6, color: SayoColors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: SayoColors.orange, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('En mora (${_delinquent.where((c) => c.status == 'en_mora').length})', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed)),
                      ]),
                      Row(children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: SayoColors.red, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('Vencido (${_delinquent.where((c) => c.status == 'vencido').length})', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed)),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: _TabButton('Cuentas en mora', 0, _tabIndex, () => setState(() => _tabIndex = 0))),
                const SizedBox(width: 8),
                Expanded(child: _TabButton('Planes de pago', 1, _tabIndex, () => setState(() => _tabIndex = 1))),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Content
          Expanded(
            child: _tabIndex == 0
                ? _buildDelinquentList()
                : _buildPaymentPlans(),
          ),
        ],
      ),
    );
  }

  Widget _buildDelinquentList() {
    if (_delinquent.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 48, color: SayoColors.green.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('Sin cuentas en mora', style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w600, color: SayoColors.grisLight)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _delinquent.length,
      itemBuilder: (ctx, i) => _DelinquentCard(
        credit: _delinquent[i],
        onSendNotice: () => _sendNotice(_delinquent[i]),
        onCreatePlan: () => _createPaymentPlan(_delinquent[i]),
        onViewUser: () => context.push('/admin/wallets/detail', extra: {'userId': _delinquent[i].userId}),
      ),
    );
  }

  Widget _buildPaymentPlans() {
    // Mock payment plans
    final plans = [
      _PaymentPlanData('Carlos Mendoza Ruiz', 'Credito Nomina', 48500, 3, 1, 16167, SayoColors.orange),
      _PaymentPlanData('Fernando Reyes', 'Credito Simple', 120000, 6, 0, 20000, SayoColors.red),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: plans.length,
      itemBuilder: (ctx, i) => _PaymentPlanCard(plan: plans[i]),
    );
  }

  void _sendNotice(CreditAssignment credit) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Aviso de cobranza enviado a ${credit.userName}', style: GoogleFonts.urbanist()),
        backgroundColor: SayoColors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _createPaymentPlan(CreditAssignment credit) {
    int installments = 3;
    final debt = credit.monthlyPayment * credit.remainingMonths;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: SayoColors.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Plan de pago para ${credit.userName}', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: SayoColors.gris)),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
                child: Column(
                  children: [
                    _InfoRow('Deuda total', formatMoney(debt)),
                    const SizedBox(height: 6),
                    _InfoRow('Producto', credit.productLabel),
                    const SizedBox(height: 6),
                    _InfoRow('Pagos vencidos', '${credit.plazoMonths - credit.paidMonths - credit.remainingMonths + (credit.status == "en_mora" ? 1 : 2)}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text('Parcialidades: $installments', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
              Slider(
                value: installments.toDouble(),
                min: 1, max: 12, divisions: 11,
                activeColor: SayoColors.green,
                onChanged: (v) => setModalState(() => installments = v.round()),
              ),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: SayoColors.green.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pago mensual', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
                    Text(formatMoney(debt / installments), style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: SayoColors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Plan de $installments pagos creado para ${credit.userName}', style: GoogleFonts.urbanist()),
                        backgroundColor: SayoColors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Crear plan'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// --- MODELS ---

class _PaymentPlanData {
  final String userName;
  final String product;
  final double totalDebt;
  final int totalInstallments;
  final int paidInstallments;
  final double installmentAmount;
  final Color color;

  const _PaymentPlanData(this.userName, this.product, this.totalDebt, this.totalInstallments, this.paidInstallments, this.installmentAmount, this.color);
}

// --- WIDGETS ---

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryItem(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final int index;
  final int current;
  final VoidCallback onTap;
  const _TabButton(this.label, this.index, this.current, this.onTap);
  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? SayoColors.cafe.withValues(alpha: 0.1) : SayoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? SayoColors.cafe : SayoColors.beige, width: isActive ? 1.5 : 0.5),
        ),
        child: Center(child: Text(label, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? SayoColors.cafe : SayoColors.grisMed))),
      ),
    );
  }
}

class _DelinquentCard extends StatelessWidget {
  final CreditAssignment credit;
  final VoidCallback onSendNotice;
  final VoidCallback onCreatePlan;
  final VoidCallback onViewUser;

  const _DelinquentCard({required this.credit, required this.onSendNotice, required this.onCreatePlan, required this.onViewUser});

  @override
  Widget build(BuildContext context) {
    final daysOverdue = DateTime.now().difference(credit.nextPaymentDate).inDays;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SayoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: credit.statusColor.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: credit.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(credit.productIcon, color: credit.statusColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onViewUser,
                    child: Text(credit.userName, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.cafe, decoration: TextDecoration.underline)),
                  ),
                  Text('${credit.productLabel}  ·  $daysOverdue dias de atraso', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                ],
              )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatMoney(credit.usedAmount), style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: credit.statusColor)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: credit.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(credit.statusLabel, style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w600, color: credit.statusColor)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSendNotice,
                  icon: const Icon(Icons.send_rounded, size: 14),
                  label: Text('Aviso', style: GoogleFonts.urbanist(fontSize: 12)),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCreatePlan,
                  icon: const Icon(Icons.description_rounded, size: 14),
                  label: Text('Plan de pago', style: GoogleFonts.urbanist(fontSize: 12)),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentPlanCard extends StatelessWidget {
  final _PaymentPlanData plan;

  const _PaymentPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.userName, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                  Text(plan.product, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                ],
              )),
              Text(formatMoney(plan.totalDebt), style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: plan.color)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: plan.totalInstallments > 0 ? plan.paidInstallments / plan.totalInstallments : 0,
              backgroundColor: SayoColors.beige.withValues(alpha: 0.5),
              valueColor: const AlwaysStoppedAnimation(SayoColors.green),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${plan.paidInstallments}/${plan.totalInstallments} pagos', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
              Text('${formatMoney(plan.installmentAmount)}/mes', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
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
