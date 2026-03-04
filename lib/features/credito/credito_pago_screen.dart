import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/data/mock_data.dart';
import 'credit_product_model.dart';

class CreditoPagoScreen extends StatefulWidget {
  final CreditProduct product;

  const CreditoPagoScreen({super.key, required this.product});

  @override
  State<CreditoPagoScreen> createState() => _CreditoPagoScreenState();
}

class _CreditoPagoScreenState extends State<CreditoPagoScreen> {
  int _step = 0;
  int _pagoType = 0; // 0=mensual, 1=capital, 2=liquidacion
  double _pagoCapitalMonto = 5000;
  bool _cuentaSayo = true;
  bool _aceptoTerminos = false;
  String _referencia = '';

  Color get _color => widget.product.color;

  double get _monthlyPayment {
    final rate = widget.product.rate / 12;
    final n = 12; // assume 12 months remaining
    final balance = widget.product.activeUsed;
    if (rate == 0) return balance / n;
    return balance * (rate * _pow(1 + rate, n)) / (_pow(1 + rate, n) - 1);
  }

  double _pow(double base, int exp) {
    double result = 1;
    for (var i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  double get _monthlyInterest => widget.product.activeUsed * (widget.product.rate / 12);
  double get _monthlyCapital => _monthlyPayment - _monthlyInterest;

  double get _pagoAmount {
    switch (_pagoType) {
      case 0: return _monthlyPayment;
      case 1: return _pagoCapitalMonto;
      case 2: return widget.product.activeUsed + _monthlyInterest;
      default: return _monthlyPayment;
    }
  }

  String get _pagoTypeLabel {
    switch (_pagoType) {
      case 0: return 'Pago mensual';
      case 1: return 'Pago a capital';
      case 2: return 'Liquidacion total';
      default: return 'Pago mensual';
    }
  }

  bool get _canContinue {
    switch (_step) {
      case 0: return true;
      case 1: return true;
      case 2: return _aceptoTerminos;
      default: return true;
    }
  }

  void _nextStep() {
    if (_step < 3) {
      setState(() {
        _step++;
        if (_step == 2) _aceptoTerminos = false;
      });
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      context.pop();
    }
  }

  void _goToReceipt() {
    final random = Random();
    _referencia = 'PAG${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}${random.nextInt(9999).toString().padLeft(4, '0')}';
    _nextStep();
  }

  String get _stepTitle {
    return ['Tipo de pago', 'Origen del pago', 'Confirmacion', 'Comprobante'][_step];
  }

  String get _buttonLabel {
    if (_step == 2) return 'Confirmar pago';
    if (_step == 3) return 'Volver a Credito';
    return 'Continuar';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0 || _step == 3,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _prevStep();
      },
      child: Scaffold(
        backgroundColor: SayoColors.cream,
        body: Column(
          children: [
            // Header
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _step == 3 ? () => context.pop() : _prevStep,
                      icon: Icon(
                        _step == 3 ? Icons.close_rounded : Icons.arrow_back_rounded,
                        color: SayoColors.gris,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Pagar ${widget.product.shortName}',
                            style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris),
                          ),
                          Text(
                            _stepTitle,
                            style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_step + 1) / 4,
                  backgroundColor: SayoColors.beige,
                  valueColor: AlwaysStoppedAnimation(_color),
                  minHeight: 4,
                ),
              ),
            ),

            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStep(),
              ),
            ),

            // Bottom button
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
              decoration: BoxDecoration(
                color: SayoColors.cream,
                border: Border(top: BorderSide(color: SayoColors.beige.withValues(alpha: 0.5))),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canContinue
                      ? () {
                          if (_step == 3) {
                            context.pop();
                          } else if (_step == 2) {
                            _goToReceipt();
                          } else {
                            _nextStep();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _step == 3 ? SayoColors.cafe : _color,
                    disabledBackgroundColor: SayoColors.beige,
                    foregroundColor: SayoColors.white,
                    disabledForegroundColor: SayoColors.grisMed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    _buttonLabel,
                    style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _PagoStep0(key: const ValueKey('p0'), parent: this);
      case 1: return _PagoStep1(key: const ValueKey('p1'), parent: this);
      case 2: return _PagoStep2(key: const ValueKey('p2'), parent: this);
      case 3: return _PagoStep3(key: const ValueKey('p3'), parent: this);
      default: return const SizedBox();
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// Step 0: Tipo de pago
// ═══════════════════════════════════════════════════════════════

class _PagoStep0 extends StatelessWidget {
  final _CreditoPagoScreenState parent;
  const _PagoStep0({super.key, required this.parent});

  @override
  Widget build(BuildContext context) {
    final p = parent.widget.product;
    final nextPaymentDate = DateTime.now().add(const Duration(days: 28));
    final daysUntil = nextPaymentDate.difference(DateTime.now()).inDays;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Next payment card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [parent._color.withValues(alpha: 0.1), parent._color.withValues(alpha: 0.04)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: parent._color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: parent._color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.calendar_today_rounded, color: parent._color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Proximo pago', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
                      Text(
                        formatMoney(parent._monthlyPayment),
                        style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: parent._color),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatDate(nextPaymentDate), style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.gris)),
                    Text('En $daysUntil dias', style: GoogleFonts.urbanist(fontSize: 11, color: parent._color, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text('Tipo de pago', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.gris)),
          const SizedBox(height: 10),

          // Pago mensual
          _PagoOption(
            title: 'Pago del mes',
            subtitle: formatMoney(parent._monthlyPayment),
            description: 'Capital ${formatMoney(parent._monthlyCapital)} + Interes ${formatMoney(parent._monthlyInterest)}',
            icon: Icons.event_rounded,
            selected: parent._pagoType == 0,
            color: parent._color,
            onTap: () => parent.setState(() => parent._pagoType = 0),
          ),
          const SizedBox(height: 8),

          // Pago a capital
          _PagoOption(
            title: 'Pago a capital',
            subtitle: 'Reduce tu saldo pendiente',
            description: 'Abono directo al capital, reduce plazo e intereses',
            icon: Icons.trending_down_rounded,
            selected: parent._pagoType == 1,
            color: parent._color,
            onTap: () => parent.setState(() => parent._pagoType = 1),
          ),

          if (parent._pagoType == 1) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SayoColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SayoColors.beige),
              ),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      formatMoney(parent._pagoCapitalMonto),
                      style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.w800, color: parent._color),
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: parent._color,
                      thumbColor: parent._color,
                      inactiveTrackColor: SayoColors.beige,
                      overlayColor: parent._color.withValues(alpha: 0.1),
                    ),
                    child: Slider(
                      value: parent._pagoCapitalMonto.clamp(1000, p.activeUsed),
                      min: 1000,
                      max: p.activeUsed,
                      divisions: 20,
                      onChanged: (v) => parent.setState(() => parent._pagoCapitalMonto = v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatMoney(1000), style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
                      Text(formatMoney(p.activeUsed), style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Liquidacion total
          _PagoOption(
            title: 'Liquidacion total',
            subtitle: formatMoney(p.activeUsed + parent._monthlyInterest),
            description: 'Liquida tu credito completo incluyendo intereses',
            icon: Icons.check_circle_outline_rounded,
            selected: parent._pagoType == 2,
            color: parent._color,
            onTap: () => parent.setState(() => parent._pagoType = 2),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Step 1: Origen del pago
// ═══════════════════════════════════════════════════════════════

class _PagoStep1 extends StatelessWidget {
  final _CreditoPagoScreenState parent;
  const _PagoStep1({super.key, required this.parent});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment amount summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: parent._color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: parent._color.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Text(parent._pagoTypeLabel, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
                const SizedBox(height: 4),
                Text(
                  formatMoney(parent._pagoAmount),
                  style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.w800, color: parent._color),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text('Origen del pago', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.gris)),
          const SizedBox(height: 10),

          // Saldo SAYO
          GestureDetector(
            onTap: () => parent.setState(() => parent._cuentaSayo = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: parent._cuentaSayo ? parent._color.withValues(alpha: 0.06) : SayoColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: parent._cuentaSayo ? parent._color : SayoColors.beige,
                  width: parent._cuentaSayo ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: parent._color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.account_balance_rounded, color: parent._color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Saldo SAYO', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: SayoColors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Recomendada', style: GoogleFonts.urbanist(fontSize: 9, fontWeight: FontWeight.w600, color: SayoColors.green)),
                            ),
                          ],
                        ),
                        Text(
                          'Disponible: ${formatMoney(MockUser.balance)}',
                          style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: parent._cuentaSayo ? parent._color : Colors.transparent,
                      border: Border.all(color: parent._cuentaSayo ? parent._color : SayoColors.beige, width: 2),
                    ),
                    child: parent._cuentaSayo ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Cuenta externa
          GestureDetector(
            onTap: () => parent.setState(() => parent._cuentaSayo = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: !parent._cuentaSayo ? parent._color.withValues(alpha: 0.06) : SayoColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: !parent._cuentaSayo ? parent._color : SayoColors.beige,
                  width: !parent._cuentaSayo ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: parent._color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.swap_horiz_rounded, color: parent._color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Referencia bancaria', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                        Text('Paga desde tu banca en linea', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed)),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !parent._cuentaSayo ? parent._color : Colors.transparent,
                      border: Border.all(color: !parent._cuentaSayo ? parent._color : SayoColors.beige, width: 2),
                    ),
                    child: !parent._cuentaSayo ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                  ),
                ],
              ),
            ),
          ),

          if (parent._cuentaSayo && parent._pagoAmount > MockUser.balance) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SayoColors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SayoColors.red.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, size: 18, color: SayoColors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Saldo insuficiente. Necesitas ${formatMoney(parent._pagoAmount - MockUser.balance)} adicionales.',
                      style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Step 2: Confirmacion
// ═══════════════════════════════════════════════════════════════

class _PagoStep2 extends StatelessWidget {
  final _CreditoPagoScreenState parent;
  const _PagoStep2({super.key, required this.parent});

  @override
  Widget build(BuildContext context) {
    final p = parent.widget.product;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Big amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [parent._color.withValues(alpha: 0.1), parent._color.withValues(alpha: 0.03)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: parent._color.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Text(parent._pagoTypeLabel, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
                const SizedBox(height: 4),
                Text(
                  formatMoney(parent._pagoAmount),
                  style: GoogleFonts.urbanist(fontSize: 36, fontWeight: FontWeight.w800, color: parent._color),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SayoColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SayoColors.beige, width: 0.5),
            ),
            child: Column(
              children: [
                _PagoRow('Credito', p.name),
                _PagoRow('Tipo de pago', parent._pagoTypeLabel),
                _PagoRow('Monto', formatMoney(parent._pagoAmount)),
                if (parent._pagoType == 0) ...[
                  _PagoRow('Capital', formatMoney(parent._monthlyCapital)),
                  _PagoRow('Interes', formatMoney(parent._monthlyInterest)),
                ],
                if (parent._pagoType == 2) ...[
                  _PagoRow('Saldo capital', formatMoney(p.activeUsed)),
                  _PagoRow('Intereses', formatMoney(parent._monthlyInterest)),
                ],
                const Divider(height: 16),
                _PagoRow('Origen', parent._cuentaSayo ? 'Saldo SAYO' : 'Referencia bancaria'),
                _PagoRow('Saldo despues', formatMoney(
                  parent._cuentaSayo ? (MockUser.balance - parent._pagoAmount) : MockUser.balance,
                )),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Checkbox
          GestureDetector(
            onTap: () => parent.setState(() => parent._aceptoTerminos = !parent._aceptoTerminos),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: parent._aceptoTerminos ? parent._color : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: parent._aceptoTerminos ? parent._color : SayoColors.beige,
                      width: 2,
                    ),
                  ),
                  child: parent._aceptoTerminos
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Confirmo que deseo realizar este pago y acepto que se aplique a mi credito de manera inmediata.',
                    style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Step 3: Comprobante
// ═══════════════════════════════════════════════════════════════

class _PagoStep3 extends StatelessWidget {
  final _CreditoPagoScreenState parent;
  const _PagoStep3({super.key, required this.parent});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: SayoColors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 44, color: SayoColors.green),
          ),
          const SizedBox(height: 20),

          Text(
            'Pago aplicado',
            style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: SayoColors.gris),
          ),
          const SizedBox(height: 6),
          Text(
            'Tu pago ha sido aplicado exitosamente\na tu credito ${parent.widget.product.shortName}.',
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed, height: 1.5),
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SayoColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SayoColors.beige, width: 0.5),
            ),
            child: Column(
              children: [
                _PagoRow('Monto pagado', formatMoney(parent._pagoAmount)),
                _PagoRow('Tipo', parent._pagoTypeLabel),
                _PagoRow('Credito', parent.widget.product.name),
                _PagoRow('Origen', parent._cuentaSayo ? 'Saldo SAYO' : 'Referencia bancaria'),
                const Divider(height: 16),
                _PagoRow('Referencia', parent._referencia),
                _PagoRow('Fecha', formatDate(DateTime.now())),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Copy reference
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: parent._referencia));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Referencia copiada'),
                  backgroundColor: parent._color,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: parent._color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: parent._color.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy_rounded, size: 16, color: parent._color),
                  const SizedBox(width: 8),
                  Text(
                    'Copiar referencia',
                    style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: parent._color),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Shared widgets
// ═══════════════════════════════════════════════════════════════

class _PagoOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _PagoOption({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.06) : SayoColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : SayoColors.beige,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                  Text(subtitle, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                  Text(description, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? color : Colors.transparent,
                border: Border.all(color: selected ? color : SayoColors.beige, width: 2),
              ),
              child: selected ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PagoRow extends StatelessWidget {
  final String label;
  final String value;
  const _PagoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
