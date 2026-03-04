import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/data/mock_data.dart';
import 'credit_product_model.dart';

class CreditoScreen extends StatefulWidget {
  const CreditoScreen({super.key});

  @override
  State<CreditoScreen> createState() => _CreditoScreenState();
}

class _CreditoScreenState extends State<CreditoScreen> {
  int _selectedProduct = 0;
  double _simAmount = 10000;
  int _simPlazo = 6;

  CreditProduct get _product => creditProducts[_selectedProduct];

  void _onProductChanged(int index) {
    setState(() {
      _selectedProduct = index;
      final p = creditProducts[index];
      _simAmount = (p.minAmount + p.activeAvailable) / 2;
      _simAmount = _simAmount.clamp(p.minAmount, p.activeAvailable > 0 ? p.activeAvailable : p.maxAmount);
      _simPlazo = ((p.minPlazo + p.maxPlazo) / 2).round();
    });
  }

  double get _monthlyPayment {
    final rate = _product.rate / 12;
    final n = _simPlazo;
    if (rate == 0) return _simAmount / n;
    return _simAmount * (rate * _pow(1 + rate, n)) / (_pow(1 + rate, n) - 1);
  }

  double _pow(double base, int exp) {
    double result = 1;
    for (var i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  List<CreditPayment> get _productPayments {
    if (!_product.hasActiveCredit) return [];
    final total = _product.activeUsed;
    final months = _product.id == 'adelanto' ? 3 : 12;
    final rate = _product.rate / 12;
    final monthlyTotal = total * (rate * _pow(1 + rate, months)) / (_pow(1 + rate, months) - 1);
    final monthlyInterest = total * rate;
    final monthlyCapital = monthlyTotal - monthlyInterest;

    return List.generate(months, (i) {
      final date = DateTime.now().add(Duration(days: 30 * (i + 1)));
      final remaining = total - (monthlyCapital * (i + 1));
      return CreditPayment(
        id: '${_product.id}_p${i + 1}',
        number: i + 1,
        date: date,
        capital: monthlyCapital,
        interest: monthlyInterest,
        total: monthlyTotal,
        remainingBalance: remaining > 0 ? remaining : 0,
        isPaid: i < (_product.id == 'adelanto' ? 1 : 2),
      );
    });
  }

  void _disponer() {
    if (_product.id == 'adelanto') {
      context.push('/adelanto');
    } else {
      context.push('/credito/disponer', extra: {
        'productId': _product.id,
        'amount': _simAmount,
        'plazo': _simPlazo,
      });
    }
  }

  void _pagar() {
    context.push('/credito/pagar', extra: {
      'productId': _product.id,
    });
  }

  void _showPaymentDetail(CreditPayment p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: SayoColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: p.isPaid
                          ? SayoColors.green.withValues(alpha: 0.1)
                          : _product.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: p.isPaid
                          ? const Icon(Icons.check_rounded, color: SayoColors.green)
                          : Text('${p.number}', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: _product.color)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pago #${p.number}', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
                      Text(
                        p.isPaid ? 'Pagado' : 'Pendiente',
                        style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: p.isPaid ? SayoColors.green : _product.color),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _product.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _product.shortName,
                      style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: _product.color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SayoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SayoColors.beige, width: 0.5),
                ),
                child: Column(
                  children: [
                    _SummaryRow('Fecha', formatDate(p.date)),
                    _SummaryRow('Capital', formatMoney(p.capital)),
                    _SummaryRow('Interes', formatMoney(p.interest)),
                    _SummaryRow('Total pago', formatMoney(p.total)),
                    const Divider(height: 16),
                    _SummaryRow('Saldo restante', formatMoney(p.remainingBalance)),
                  ],
                ),
              ),
              if (!p.isPaid) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _pagar();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SayoColors.cafe,
                      foregroundColor: SayoColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Realizar pago', style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showNextPaymentDetail() {
    final payments = _productPayments;
    if (payments.isEmpty) return;
    final nextPayment = payments.firstWhere((p) => !p.isPaid, orElse: () => payments.last);
    _showPaymentDetail(nextPayment);
  }

  void _showAllPayments() {
    final payments = _productPayments;
    if (payments.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: SayoColors.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_product.name} (${payments.length} pagos)',
                            style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris),
                          ),
                          Text(
                            'Tasa: ${(_product.rate * 100).toStringAsFixed(1)}% anual',
                            style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close_rounded, color: SayoColors.grisMed),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: payments.length,
                  itemBuilder: (context, i) {
                    final p = payments[i];
                    return _PaymentRow(
                      payment: p,
                      color: _product.color,
                      onTap: () {
                        Navigator.pop(context);
                        _showPaymentDetail(p);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payments = _productPayments;
    final maxSimAmount = _product.activeAvailable > 0 ? _product.activeAvailable : _product.maxAmount;
    final clampedAmount = _simAmount.clamp(_product.minAmount, maxSimAmount);
    if (clampedAmount != _simAmount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _simAmount = clampedAmount);
      });
    }
    final clampedPlazo = _simPlazo.clamp(_product.minPlazo, _product.maxPlazo);
    if (clampedPlazo != _simPlazo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _simPlazo = clampedPlazo);
      });
    }

    return Scaffold(
      backgroundColor: SayoColors.cream,
      body: CustomScrollView(
        slivers: [
          // Title
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20, right: 20, bottom: 8,
              ),
              child: Text(
                'Credito',
                style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.w800, color: SayoColors.gris),
              ),
            ),
          ),

          // Product selector
          SliverToBoxAdapter(
            child: SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: creditProducts.length,
                itemBuilder: (context, i) {
                  final p = creditProducts[i];
                  final selected = i == _selectedProduct;
                  return GestureDetector(
                    onTap: () => _onProductChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      width: 155,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected ? p.color : SayoColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? p.color : SayoColors.beige,
                          width: selected ? 2 : 0.5,
                        ),
                        boxShadow: selected
                            ? [BoxShadow(color: p.color.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))]
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: selected ? Colors.white.withValues(alpha: 0.2) : p.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(p.icon, size: 20, color: selected ? Colors.white : p.color),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            p.shortName,
                            style: GoogleFonts.urbanist(
                              fontSize: 14, fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : SayoColors.gris,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${(p.rate * 100).toStringAsFixed(0)}% anual',
                            style: GoogleFonts.urbanist(
                              fontSize: 11,
                              color: selected ? Colors.white.withValues(alpha: 0.8) : SayoColors.grisLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Product description
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _product.color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _product.color.withValues(alpha: 0.12)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: _product.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _product.description,
                        style: GoogleFonts.urbanist(fontSize: 12, color: _product.color, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Credit gauge (if has active credit)
          if (_product.hasActiveCredit)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: SayoColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: SayoColors.beige, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      CircularPercentIndicator(
                        radius: 70,
                        lineWidth: 11,
                        percent: _product.usedPercent,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(_product.usedPercent * 100).toInt()}%',
                              style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.w800, color: SayoColors.gris),
                            ),
                            Text('Utilizado', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                          ],
                        ),
                        progressColor: _product.color,
                        backgroundColor: SayoColors.beige.withValues(alpha: 0.5),
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                        animationDuration: 800,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _CreditMetric('Limite', formatMoney(_product.activeLimit), SayoColors.grisMed),
                          Container(width: 1, height: 30, color: SayoColors.beige),
                          _CreditMetric('Usado', formatMoney(_product.activeUsed), _product.color),
                          Container(width: 1, height: 30, color: SayoColors.beige),
                          _CreditMetric('Disponible', formatMoney(_product.activeAvailable), SayoColors.green),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // No active credit — apply CTA
          if (!_product.hasActiveCredit)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: SayoColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: SayoColors.beige, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: _product.color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_product.icon, size: 28, color: _product.color),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Disponible hasta ${formatMoney(_product.maxAmount)}',
                        style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _product.id == 'simple'
                            ? 'Solicita tu credito simple y recibe respuesta en 24-48 horas. Usa el simulador para cotizar.'
                            : 'Aun no tienes un credito activo de este tipo. Usa el simulador para cotizar y disponer.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed),
                      ),
                      if (_product.id == 'simple') ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _disponer,
                            icon: const Icon(Icons.description_rounded, size: 18),
                            label: Text('Solicitar Credito', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _product.color,
                              foregroundColor: SayoColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          // Next payment + Pagar button (if active credit)
          if (_product.hasActiveCredit && payments.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showNextPaymentDetail,
                      child: Builder(
                        builder: (context) {
                          final nextP = payments.firstWhere((p) => !p.isPaid, orElse: () => payments.last);
                          final daysUntil = nextP.date.difference(DateTime.now()).inDays;
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_product.color.withValues(alpha: 0.06), _product.color.withValues(alpha: 0.02)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _product.color.withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _product.color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.calendar_today_rounded, color: _product.color, size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Proximo pago', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
                                      Text(
                                        formatMoney(nextP.total),
                                        style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w800, color: _product.color),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatDate(nextP.date),
                                      style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris),
                                    ),
                                    Text(
                                      'En $daysUntil dias',
                                      style: GoogleFonts.urbanist(fontSize: 11, color: _product.color, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right_rounded, size: 20, color: SayoColors.grisMed),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Pagar button
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _pagar,
                        icon: Icon(Icons.payment_rounded, size: 18, color: _product.color),
                        label: Text(
                          'Realizar pago',
                          style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: _product.color),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _product.color, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Simulator header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Simulador',
                style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris),
              ),
            ),
          ),

          // Simulator
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Monto', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
                        Text(
                          formatMoney(_simAmount),
                          style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: _product.color),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _product.color,
                        thumbColor: _product.color,
                        inactiveTrackColor: SayoColors.beige,
                        overlayColor: _product.color.withValues(alpha: 0.1),
                      ),
                      child: Slider(
                        value: _simAmount.clamp(_product.minAmount, maxSimAmount),
                        min: _product.minAmount,
                        max: maxSimAmount,
                        divisions: 20,
                        onChanged: (v) => setState(() => _simAmount = v),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatMoney(_product.minAmount), style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
                        Text(formatMoney(maxSimAmount), style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Plazo', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
                        Text(
                          '$_simPlazo meses',
                          style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: _product.color),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _product.color,
                        thumbColor: _product.color,
                        inactiveTrackColor: SayoColors.beige,
                        overlayColor: _product.color.withValues(alpha: 0.1),
                      ),
                      child: Slider(
                        value: _simPlazo.toDouble().clamp(_product.minPlazo.toDouble(), _product.maxPlazo.toDouble()),
                        min: _product.minPlazo.toDouble(),
                        max: _product.maxPlazo.toDouble(),
                        divisions: _product.plazoDivisions,
                        onChanged: (v) => setState(() => _simPlazo = v.toInt()),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_product.minPlazo} meses', style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
                        Text('${_product.maxPlazo} meses', style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _product.color.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pago mensual', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
                              Text(
                                formatMoney(_monthlyPayment),
                                style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: _product.color),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Tasa anual', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
                              Text(
                                '${(_product.rate * 100).toStringAsFixed(1)}%',
                                style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _disponer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _product.color,
                          foregroundColor: SayoColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          _product.needsApplication ? 'Solicitar ${_product.shortName}' : 'Disponer ${_product.shortName}',
                          style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Amortization table (if active credit)
          if (_product.hasActiveCredit && payments.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tabla de amortizacion', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                    GestureDetector(
                      onTap: _showAllPayments,
                      child: Text('Ver todo', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: _product.color)),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.builder(
                itemCount: payments.take(5).length,
                itemBuilder: (context, i) {
                  final p = payments[i];
                  return _PaymentRow(
                    payment: p,
                    color: _product.color,
                    onTap: () => _showPaymentDetail(p),
                  );
                },
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final CreditPayment payment;
  final Color color;
  final VoidCallback onTap;

  const _PaymentRow({required this.payment, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = payment;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: p.isPaid ? SayoColors.green.withValues(alpha: 0.04) : SayoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: p.isPaid ? SayoColors.green.withValues(alpha: 0.2) : SayoColors.beige,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: p.isPaid ? SayoColors.green.withValues(alpha: 0.1) : SayoColors.beige.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: p.isPaid
                    ? const Icon(Icons.check_rounded, size: 16, color: SayoColors.green)
                    : Text('${p.number}', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w700, color: SayoColors.grisMed)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatDate(p.date), style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
                  Text(
                    'Capital ${formatMoney(p.capital)} + Interes ${formatMoney(p.interest)}',
                    style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight),
                  ),
                ],
              ),
            ),
            Text(
              formatMoney(p.total),
              style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: p.isPaid ? SayoColors.green : SayoColors.gris),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 16, color: SayoColors.grisLight),
          ],
        ),
      ),
    );
  }
}

class _CreditMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CreditMetric(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
          Text(value, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
        ],
      ),
    );
  }
}
