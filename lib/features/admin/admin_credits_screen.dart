import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import 'admin_mock_data.dart';

class AdminCreditsScreen extends StatefulWidget {
  const AdminCreditsScreen({super.key});

  @override
  State<AdminCreditsScreen> createState() => _AdminCreditsScreenState();
}

class _AdminCreditsScreenState extends State<AdminCreditsScreen> {
  String _statusFilter = 'todos';
  String _productFilter = 'todos';

  List<CreditAssignment> get _filtered {
    var list = List<CreditAssignment>.from(mockCreditAssignments);

    if (_statusFilter != 'todos') {
      list = list.where((c) => c.status == _statusFilter).toList();
    }
    if (_productFilter != 'todos') {
      list = list.where((c) => c.productType == _productFilter).toList();
    }

    list.sort((a, b) {
      // en_mora and vencido first
      final aP = (a.status == 'en_mora' || a.status == 'vencido') ? 0 : 1;
      final bP = (b.status == 'en_mora' || b.status == 'vencido') ? 0 : 1;
      if (aP != bP) return aP.compareTo(bP);
      return b.usedAmount.compareTo(a.usedAmount);
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final credits = _filtered;
    final totalColocado = credits.fold(0.0, (sum, c) => sum + c.usedAmount);
    final totalMensual = credits.where((c) => c.status == 'vigente').fold(0.0, (sum, c) => sum + c.monthlyPayment);

    return Scaffold(
      backgroundColor: SayoColors.cream,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1D1F25), Color(0xFF2E3440)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Seguimiento de Creditos',
                          style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Summary cards
                  Row(
                    children: [
                      Expanded(child: _SummaryCard('Colocado', formatMoney(totalColocado), SayoColors.blue)),
                      const SizedBox(width: 8),
                      Expanded(child: _SummaryCard('Cobranza/mes', formatMoney(totalMensual), SayoColors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _SummaryCard('En riesgo', formatMoney(AdminSummary.atRiskAmount), SayoColors.red)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Status distribution
                  Row(
                    children: [
                      _StatusDot('Vigente', AdminSummary.activeCredits, SayoColors.green),
                      const SizedBox(width: 16),
                      _StatusDot('En mora', mockCreditAssignments.where((c) => c.status == 'en_mora').length, SayoColors.orange),
                      const SizedBox(width: 16),
                      _StatusDot('Vencido', mockCreditAssignments.where((c) => c.status == 'vencido').length, SayoColors.red),
                      const SizedBox(width: 16),
                      _StatusDot('Liquidado', AdminSummary.settledCredits, SayoColors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estado', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ChipFilter('Todos', _statusFilter == 'todos', () => setState(() => _statusFilter = 'todos')),
                        _ChipFilter('Vigente', _statusFilter == 'vigente', () => setState(() => _statusFilter = 'vigente'), color: SayoColors.green),
                        _ChipFilter('En mora', _statusFilter == 'en_mora', () => setState(() => _statusFilter = 'en_mora'), color: SayoColors.orange),
                        _ChipFilter('Vencido', _statusFilter == 'vencido', () => setState(() => _statusFilter = 'vencido'), color: SayoColors.red),
                        _ChipFilter('Liquidado', _statusFilter == 'liquidado', () => setState(() => _statusFilter = 'liquidado'), color: SayoColors.blue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Producto', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ChipFilter('Todos', _productFilter == 'todos', () => setState(() => _productFilter = 'todos')),
                        _ChipFilter('Adelanto', _productFilter == 'adelanto', () => setState(() => _productFilter = 'adelanto'), color: SayoColors.orange),
                        _ChipFilter('Nomina', _productFilter == 'nomina', () => setState(() => _productFilter = 'nomina'), color: SayoColors.green),
                        _ChipFilter('Simple', _productFilter == 'simple', () => setState(() => _productFilter = 'simple'), color: SayoColors.blue),
                        _ChipFilter('Revolvente', _productFilter == 'revolvente', () => setState(() => _productFilter = 'revolvente'), color: SayoColors.purple),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text('${credits.length} creditos', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
            ),
          ),

          // Credit list
          credits.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.credit_card_off_rounded, size: 48, color: SayoColors.grisLight.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text('Sin creditos en esta categoria', style: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.grisLight)),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.builder(
                    itemCount: credits.length,
                    itemBuilder: (ctx, i) => GestureDetector(
                      onTap: () => _showCreditDetail(context, credits[i]),
                      child: _CreditCard(credit: credits[i]),
                    ),
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  void _showCreditDetail(BuildContext context, CreditAssignment credit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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

            // Product header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: credit.productColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                  child: Icon(credit.productIcon, color: credit.productColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(credit.productLabel, style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: SayoColors.gris)),
                      Text(credit.userName, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: credit.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(credit.statusLabel, style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w700, color: credit.statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Amount bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: credit.usedPercent,
                backgroundColor: SayoColors.beige.withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation(credit.productColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Usado: ${formatMoney(credit.usedAmount)}', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: credit.productColor)),
                Text('Limite: ${formatMoney(credit.assignedLimit)}', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
              ],
            ),
            const SizedBox(height: 16),

            // Details
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SayoColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SayoColors.beige, width: 0.5),
              ),
              child: Column(
                children: [
                  _DetailRow('ID Credito', credit.id),
                  const SizedBox(height: 8),
                  _DetailRow('Tasa anual', '${(credit.interestRate * 100).toStringAsFixed(0)}%'),
                  const SizedBox(height: 8),
                  _DetailRow('Plazo', '${credit.plazoMonths} meses'),
                  const SizedBox(height: 8),
                  _DetailRow('Pagos realizados', '${credit.paidMonths} de ${credit.plazoMonths}'),
                  const SizedBox(height: 8),
                  _DetailRow('Pago mensual', formatMoney(credit.monthlyPayment)),
                  const SizedBox(height: 8),
                  _DetailRow('Fecha asignacion', formatDate(credit.assignedDate)),
                  const SizedBox(height: 8),
                  _DetailRow('Proximo pago', formatDate(credit.nextPaymentDate)),
                  if (credit.status == 'en_mora' || credit.status == 'vencido') ...[
                    const SizedBox(height: 8),
                    _DetailRow('Deuda estimada', formatMoney(credit.totalDebt), valueColor: SayoColors.red),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            if (credit.status == 'en_mora' || credit.status == 'vencido')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSendNotice(context, credit);
                      },
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Enviar aviso'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showPaymentPlan(context, credit);
                      },
                      icon: const Icon(Icons.description_rounded, size: 16),
                      label: const Text('Plan de pago'),
                    ),
                  ),
                ],
              ),

            // View user detail
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/admin/wallets/detail', extra: {'userId': credit.userId});
                },
                icon: const Icon(Icons.person_rounded, size: 16),
                label: const Text('Ver wallet del usuario'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
  void _showSendNotice(BuildContext context, CreditAssignment credit) {
    String? selectedChannel;
    final channels = [
      {'id': 'sms', 'label': 'SMS', 'icon': Icons.sms_rounded, 'desc': 'Mensaje de texto al celular'},
      {'id': 'email', 'label': 'Email', 'icon': Icons.email_rounded, 'desc': 'Correo electronico'},
      {'id': 'push', 'label': 'Push', 'icon': Icons.notifications_rounded, 'desc': 'Notificacion en la app'},
      {'id': 'all', 'label': 'Todos', 'icon': Icons.campaign_rounded, 'desc': 'Enviar por todos los canales'},
    ];

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
              Text('Enviar aviso de cobranza', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: SayoColors.gris)),
              const SizedBox(height: 4),
              Text('${credit.userName} · ${credit.productLabel} · ${credit.statusLabel}', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: SayoColors.orange.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  'Estimado/a ${credit.userName}, le recordamos que tiene un pago ${credit.status == 'vencido' ? 'vencido' : 'pendiente'} de ${formatMoney(credit.monthlyPayment)} correspondiente a su ${credit.productLabel}. Favor de regularizar su situacion.',
                  style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.gris),
                ),
              ),
              const SizedBox(height: 16),

              Text('Canal de envio', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
              const SizedBox(height: 8),
              ...channels.map((c) => GestureDetector(
                onTap: () => setModalState(() => selectedChannel = c['id'] as String),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedChannel == c['id'] ? SayoColors.blue.withValues(alpha: 0.06) : SayoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selectedChannel == c['id'] ? SayoColors.blue : SayoColors.beige, width: selectedChannel == c['id'] ? 1.5 : 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(c['icon'] as IconData, size: 18, color: selectedChannel == c['id'] ? SayoColors.blue : SayoColors.grisLight),
                      const SizedBox(width: 10),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['label'] as String, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
                          Text(c['desc'] as String, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                        ],
                      )),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: selectedChannel == null ? null : () {
                    Navigator.pop(ctx);
                    final channelLabel = channels.firstWhere((c) => c['id'] == selectedChannel)['label'];
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Aviso enviado a ${credit.userName} via $channelLabel', style: GoogleFonts.urbanist()),
                        backgroundColor: SayoColors.blue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Enviar aviso'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentPlan(BuildContext context, CreditAssignment credit) {
    int installments = 3;
    final debtAmount = credit.monthlyPayment * credit.remainingMonths;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final installmentAmount = debtAmount / installments;
          return Container(
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
                Text('Generar plan de pago', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: SayoColors.gris)),
                const SizedBox(height: 4),
                Text(credit.userName, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
                  child: Column(
                    children: [
                      _DetailRow('Deuda total', formatMoney(debtAmount)),
                      const SizedBox(height: 8),
                      _DetailRow('Meses restantes', '${credit.remainingMonths}'),
                      const SizedBox(height: 8),
                      _DetailRow('Producto', credit.productLabel),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Text('Parcialidades: $installments meses', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
                Slider(
                  value: installments.toDouble(),
                  min: 1,
                  max: 12,
                  divisions: 11,
                  activeColor: SayoColors.green,
                  onChanged: (v) => setModalState(() => installments = v.round()),
                ),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: SayoColors.green.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pago por parcialidad', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
                      Text(formatMoney(installmentAmount), style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: SayoColors.green)),
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
                          content: Text('Plan de $installments parcialidades de ${formatMoney(installmentAmount)} generado', style: GoogleFonts.urbanist()),
                          backgroundColor: SayoColors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Generar plan'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- WIDGETS ---

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.urbanist(fontSize: 10, color: Colors.white.withValues(alpha: 0.5))),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusDot(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label ($count)', style: GoogleFonts.urbanist(fontSize: 11, color: Colors.white.withValues(alpha: 0.6))),
      ],
    );
  }
}

class _ChipFilter extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _ChipFilter(this.label, this.isSelected, this.onTap, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? SayoColors.cafe;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? c.withValues(alpha: 0.1) : SayoColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? c : SayoColors.beige, width: isSelected ? 1.5 : 0.5),
          ),
          child: Text(label, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? c : SayoColors.grisMed)),
        ),
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  final CreditAssignment credit;

  const _CreditCard({required this.credit});

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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: credit.productColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(credit.productIcon, color: credit.productColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(credit.userName, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                    Row(
                      children: [
                        Text(credit.productLabel, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                        const SizedBox(width: 6),
                        Text('·', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                        const SizedBox(width: 6),
                        Text('${(credit.interestRate * 100).toStringAsFixed(0)}% anual', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatMoney(credit.usedAmount), style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: credit.usedPercent,
              backgroundColor: SayoColors.beige.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation(credit.productColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${credit.paidMonths}/${credit.plazoMonths} pagos', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
              Text('Pago: ${formatMoney(credit.monthlyPayment)}/mes', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
              Text('Prox: ${_shortDate(credit.nextPaymentDate)}', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
            ],
          ),
        ],
      ),
    );
  }

  String _shortDate(DateTime d) {
    const months = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${d.day} ${months[d.month]}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
        Text(value, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? SayoColors.gris)),
      ],
    );
  }
}
