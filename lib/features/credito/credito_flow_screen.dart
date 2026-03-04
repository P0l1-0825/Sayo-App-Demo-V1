import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/data/mock_data.dart';
import '../../shared/data/spei_participants.dart';
import 'credit_product_model.dart';

class CreditoFlowScreen extends StatefulWidget {
  final CreditProduct product;
  final double initialAmount;
  final int initialPlazo;

  const CreditoFlowScreen({
    super.key,
    required this.product,
    required this.initialAmount,
    required this.initialPlazo,
  });

  @override
  State<CreditoFlowScreen> createState() => _CreditoFlowScreenState();
}

class _CreditoFlowScreenState extends State<CreditoFlowScreen> {
  int _step = 0;
  late double _monto;
  late int _plazo;
  bool _cuentaSayo = true;
  bool _aceptoTerminos = false;
  final _clabeCtrl = TextEditingController();
  SpeiParticipant? _detectedBank;
  String _referencia = '';

  // Simple-specific
  int _selectedPurpose = -1;

  // Revolvente-specific
  int _quickAmountIndex = -1;
  bool _customAmount = false;

  Color get _color => widget.product.color;
  String get _productId => widget.product.id;

  int get _totalSteps {
    if (_productId == 'revolvente') return 3;
    return 4; // nomina & simple
  }

  double get _monthlyPayment {
    final rate = widget.product.rate / 12;
    final n = _plazo;
    if (rate == 0) return _monto / n;
    return _monto * (rate * _pow(1 + rate, n)) / (_pow(1 + rate, n) - 1);
  }

  double get _totalPagar => _monthlyPayment * _plazo;
  double get _totalInteres => _totalPagar - _monto;

  double _pow(double base, int exp) {
    double result = 1;
    for (var i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _monto = widget.initialAmount;
    _plazo = widget.initialPlazo;
    _clabeCtrl.addListener(_detectBank);
  }

  @override
  void dispose() {
    _clabeCtrl.dispose();
    super.dispose();
  }

  void _detectBank() {
    final text = _clabeCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (text.length >= 3) {
      final code = text.substring(0, 3);
      final bank = SpeiCatalog.fromClabe(text);
      if (bank != _detectedBank) setState(() => _detectedBank = bank);
    } else {
      if (_detectedBank != null) setState(() => _detectedBank = null);
    }
  }

  bool get _canContinue {
    switch (_productId) {
      case 'nomina':
        return _canContinueNomina();
      case 'simple':
        return _canContinueSimple();
      case 'revolvente':
        return _canContinueRevolvente();
      default:
        return true;
    }
  }

  bool _canContinueNomina() {
    switch (_step) {
      case 0: return _monto >= widget.product.minAmount;
      case 1:
        if (_cuentaSayo) return true;
        final digits = _clabeCtrl.text.replaceAll(RegExp(r'\D'), '');
        return digits.length == 18 && _detectedBank != null;
      case 2: return _aceptoTerminos;
      default: return true;
    }
  }

  bool _canContinueSimple() {
    switch (_step) {
      case 0: return _selectedPurpose >= 0 && _monto >= widget.product.minAmount;
      case 1:
        final allDocsReady = true; // mock: 3 of 4 verified
        if (_cuentaSayo) return allDocsReady;
        final digits = _clabeCtrl.text.replaceAll(RegExp(r'\D'), '');
        return digits.length == 18 && _detectedBank != null && allDocsReady;
      case 2: return _aceptoTerminos;
      default: return true;
    }
  }

  bool _canContinueRevolvente() {
    switch (_step) {
      case 0: return _monto >= widget.product.minAmount && _plazo >= 1;
      case 1: return _aceptoTerminos;
      default: return true;
    }
  }

  void _nextStep() {
    if (_step < _totalSteps - 1) {
      setState(() {
        _step++;
        _aceptoTerminos = false;
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
    _referencia = 'SAY${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}${random.nextInt(9999).toString().padLeft(4, '0')}';
    _nextStep();
  }

  String get _stepTitle {
    if (_productId == 'nomina') {
      return ['Monto y plazo', 'Cuenta destino', 'Confirmacion', 'Comprobante'][_step];
    } else if (_productId == 'simple') {
      return ['Proposito y monto', 'Documentos y cuenta', 'Confirmacion', 'Solicitud enviada'][_step];
    } else {
      return ['Monto rapido', 'Confirmacion', 'Comprobante'][_step];
    }
  }

  String get _buttonLabel {
    final isLastBeforeReceipt = _step == _totalSteps - 2;
    if (_productId == 'simple' && isLastBeforeReceipt) return 'Enviar solicitud';
    if (isLastBeforeReceipt) return 'Confirmar disposicion';
    if (_step == _totalSteps - 1) return 'Volver a Credito';
    return 'Continuar';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0 || _step == _totalSteps - 1,
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
                      onPressed: _step == _totalSteps - 1
                          ? () => context.pop()
                          : _prevStep,
                      icon: Icon(
                        _step == _totalSteps - 1
                            ? Icons.close_rounded
                            : Icons.arrow_back_rounded,
                        color: SayoColors.gris,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.product.name,
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: SayoColors.gris,
                            ),
                          ),
                          Text(
                            _stepTitle,
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              color: SayoColors.grisMed,
                            ),
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
                  value: (_step + 1) / _totalSteps,
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
            _BottomButton(
              label: _buttonLabel,
              color: _step == _totalSteps - 1 ? SayoColors.cafe : _color,
              enabled: _step == _totalSteps - 1 || _canContinue,
              onPressed: () {
                if (_step == _totalSteps - 1) {
                  context.pop();
                } else if (_step == _totalSteps - 2) {
                  _goToReceipt();
                } else {
                  _nextStep();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_productId) {
      case 'nomina':
        return _buildNominaStep();
      case 'simple':
        return _buildSimpleStep();
      case 'revolvente':
        return _buildRevolventeStep();
      default:
        return const SizedBox();
    }
  }

  // ─── NOMINA FLOW (Green, 4 steps) ─────────────────────────────

  Widget _buildNominaStep() {
    switch (_step) {
      case 0: return _NominaStep0(key: const ValueKey('n0'), parent: this);
      case 1: return _AccountStep(key: const ValueKey('n1'), parent: this);
      case 2: return _ConfirmStep(key: const ValueKey('n2'), parent: this);
      case 3: return _ReceiptStep(key: const ValueKey('n3'), parent: this);
      default: return const SizedBox();
    }
  }

  // ─── SIMPLE FLOW (Blue, 4 steps — solicitud) ──────────────────

  Widget _buildSimpleStep() {
    switch (_step) {
      case 0: return _SimpleStep0(key: const ValueKey('s0'), parent: this);
      case 1: return _SimpleStep1(key: const ValueKey('s1'), parent: this);
      case 2: return _ConfirmStep(key: const ValueKey('s2'), parent: this, isSolicitud: true);
      case 3: return _ReceiptStep(key: const ValueKey('s3'), parent: this, isSolicitud: true);
      default: return const SizedBox();
    }
  }

  // ─── REVOLVENTE FLOW (Purple, 3 steps) ────────────────────────

  Widget _buildRevolventeStep() {
    switch (_step) {
      case 0: return _RevolventeStep0(key: const ValueKey('r0'), parent: this);
      case 1: return _ConfirmStep(key: const ValueKey('r1'), parent: this);
      case 2: return _ReceiptStep(key: const ValueKey('r2'), parent: this);
      default: return const SizedBox();
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// NOMINA — Step 0: Verificacion + Monto/Plazo
// ═══════════════════════════════════════════════════════════════

class _NominaStep0 extends StatelessWidget {
  final _CreditoFlowScreenState parent;
  const _NominaStep0({super.key, required this.parent});

  @override
  Widget build(BuildContext context) {
    final p = parent.widget.product;
    final maxAmount = p.activeAvailable > 0 ? p.activeAvailable : p.maxAmount;
    final plazos = [6, 12, 18, 24, 36];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employment verification card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SayoColors.green.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SayoColors.green.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: SayoColors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.verified_rounded, color: SayoColors.green, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Empleo verificado', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.green)),
                          Text(MockEmployment.empresa, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded, color: SayoColors.green, size: 22),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _MiniInfo('Puesto', MockEmployment.puesto),
                    const SizedBox(width: 16),
                    _MiniInfo('Salario', formatMoney(MockEmployment.salarioMensual)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _MiniInfo('Antiguedad', '${(MockEmployment.antiguedadMeses / 12).floor()} años ${MockEmployment.antiguedadMeses % 12} meses'),
                    const SizedBox(width: 16),
                    _MiniInfo('Contrato', MockEmployment.tipoContrato),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Amount slider
          Text('Monto del credito', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.gris)),
          const SizedBox(height: 4),
          Center(
            child: Text(
              formatMoney(parent._monto),
              style: GoogleFonts.urbanist(fontSize: 32, fontWeight: FontWeight.w800, color: parent._color),
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
              value: parent._monto.clamp(p.minAmount, maxAmount),
              min: p.minAmount,
              max: maxAmount,
              divisions: 20,
              onChanged: (v) => parent.setState(() => parent._monto = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatMoney(p.minAmount), style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
              Text(formatMoney(maxAmount), style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
            ],
          ),

          const SizedBox(height: 20),

          // Plazo chips
          Text('Plazo', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.gris)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: plazos.map((m) {
              final selected = parent._plazo == m;
              return GestureDetector(
                onTap: () => parent.setState(() => parent._plazo = m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? parent._color : SayoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? parent._color : SayoColors.beige,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    '$m meses',
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : SayoColors.gris,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Breakdown
          _BreakdownCard(parent: parent),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SIMPLE — Step 0: Proposito + Monto/Plazo
// ═══════════════════════════════════════════════════════════════

class _SimpleStep0 extends StatelessWidget {
  final _CreditoFlowScreenState parent;
  const _SimpleStep0({super.key, required this.parent});

  @override
  Widget build(BuildContext context) {
    final p = parent.widget.product;
    final maxAmount = p.maxAmount;
    final plazos = [3, 6, 12, 18, 24, 36, 48];
    final purposes = MockCreditApplication.purposes;
    final purposeIcons = [
      Icons.business_center_rounded,
      Icons.computer_rounded,
      Icons.home_repair_service_rounded,
      Icons.account_balance_rounded,
      Icons.person_rounded,
      Icons.more_horiz_rounded,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Proposito del credito', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.gris)),
          const SizedBox(height: 10),

          // Purpose tiles
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: purposes.length,
            itemBuilder: (context, i) {
              final selected = parent._selectedPurpose == i;
              return GestureDetector(
                onTap: () => parent.setState(() => parent._selectedPurpose = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selected ? parent._color : SayoColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? parent._color : SayoColors.beige,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        purposeIcons[i],
                        size: 24,
                        color: selected ? Colors.white : parent._color,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        purposes[i],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.urbanist(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : SayoColors.gris,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Amount slider
          Text('Monto solicitado', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.gris)),
          const SizedBox(height: 4),
          Center(
            child: Text(
              formatMoney(parent._monto),
              style: GoogleFonts.urbanist(fontSize: 32, fontWeight: FontWeight.w800, color: parent._color),
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
              value: parent._monto.clamp(p.minAmount, maxAmount),
              min: p.minAmount,
              max: maxAmount,
              divisions: 20,
              onChanged: (v) => parent.setState(() => parent._monto = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatMoney(p.minAmount), style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
              Text(formatMoney(maxAmount), style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
            ],
          ),

          const SizedBox(height: 16),

          // Plazo chips
          Text('Plazo', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.gris)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: plazos.map((m) {
              final selected = parent._plazo == m;
              return GestureDetector(
                onTap: () => parent.setState(() => parent._plazo = m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? parent._color : SayoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? parent._color : SayoColors.beige,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    '$m meses',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : SayoColors.gris,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          _BreakdownCard(parent: parent),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SIMPLE — Step 1: Documentos + Cuenta
// ═══════════════════════════════════════════════════════════════

class _SimpleStep1 extends StatelessWidget {
  final _CreditoFlowScreenState parent;
  const _SimpleStep1({super.key, required this.parent});

  @override
  Widget build(BuildContext context) {
    final docs = MockCreditApplication.documents;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Documentacion requerida', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.gris)),
          const SizedBox(height: 10),

          // Documents checklist
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SayoColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SayoColors.beige, width: 0.5),
            ),
            child: Column(
              children: docs.map((doc) {
                final isVerified = doc['status'] == 'verified';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Text(doc['icon'] as String, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc['name'] as String,
                              style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris),
                            ),
                            Text(
                              isVerified ? 'Verificado' : 'Pendiente de verificacion',
                              style: GoogleFonts.urbanist(
                                fontSize: 11,
                                color: isVerified ? SayoColors.green : SayoColors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isVerified ? Icons.check_circle_rounded : Icons.schedule_rounded,
                        color: isVerified ? SayoColors.green : SayoColors.orange,
                        size: 20,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          Text('Cuenta destino', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.gris)),
          const SizedBox(height: 10),

          // Account selector (reuse same pattern)
          _AccountOption(
            title: 'Cuenta SAYO',
            subtitle: 'CLABE: ${formatClabe(MockUser.clabe)}',
            icon: Icons.account_balance_rounded,
            selected: parent._cuentaSayo,
            color: parent._color,
            recommended: true,
            onTap: () => parent.setState(() => parent._cuentaSayo = true),
          ),
          const SizedBox(height: 8),
          _AccountOption(
            title: 'Cuenta externa',
            subtitle: 'Ingresa CLABE de otro banco',
            icon: Icons.swap_horiz_rounded,
            selected: !parent._cuentaSayo,
            color: parent._color,
            onTap: () => parent.setState(() => parent._cuentaSayo = false),
          ),

          if (!parent._cuentaSayo) ...[
            const SizedBox(height: 14),
            _ClabeInput(parent: parent),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// REVOLVENTE — Step 0: Monto rapido
// ═══════════════════════════════════════════════════════════════

class _RevolventeStep0 extends StatelessWidget {
  final _CreditoFlowScreenState parent;
  const _RevolventeStep0({super.key, required this.parent});

  @override
  Widget build(BuildContext context) {
    final p = parent.widget.product;
    final available = p.activeAvailable;
    final quickAmounts = [5000.0, 10000.0, 25000.0, 50000.0];
    final plazos = [1, 3, 6, 9, 12];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available line card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [parent._color.withValues(alpha: 0.1), parent._color.withValues(alpha: 0.04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: parent._color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: parent._color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.account_balance_wallet_rounded, color: parent._color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Linea disponible', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
                      Text(
                        formatMoney(available),
                        style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.w800, color: parent._color),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Limite', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                    Text(formatMoney(p.activeLimit), style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Quick amount chips
          Text('Monto rapido', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.gris)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...quickAmounts.asMap().entries.map((entry) {
                final i = entry.key;
                final amt = entry.value;
                if (amt > available) return const SizedBox.shrink();
                final selected = parent._quickAmountIndex == i && !parent._customAmount;
                return GestureDetector(
                  onTap: () => parent.setState(() {
                    parent._quickAmountIndex = i;
                    parent._customAmount = false;
                    parent._monto = amt;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? parent._color : SayoColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? parent._color : SayoColors.beige,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      formatMoney(amt),
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : SayoColors.gris,
                      ),
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: () => parent.setState(() {
                  parent._customAmount = true;
                  parent._quickAmountIndex = -1;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: parent._customAmount ? parent._color : SayoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: parent._customAmount ? parent._color : SayoColors.beige,
                      width: parent._customAmount ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    'Otro monto',
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: parent._customAmount ? Colors.white : SayoColors.gris,
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (parent._customAmount) ...[
            const SizedBox(height: 14),
            Center(
              child: Text(
                formatMoney(parent._monto),
                style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.w800, color: parent._color),
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
                value: parent._monto.clamp(p.minAmount, available),
                min: p.minAmount,
                max: available,
                divisions: 20,
                onChanged: (v) => parent.setState(() => parent._monto = v),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatMoney(p.minAmount), style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
                Text(formatMoney(available), style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // Plazo chips
          Text('Plazo', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.gris)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: plazos.map((m) {
              final selected = parent._plazo == m;
              return GestureDetector(
                onTap: () => parent.setState(() => parent._plazo = m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? parent._color : SayoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? parent._color : SayoColors.beige,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    m == 1 ? '1 mes' : '$m meses',
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : SayoColors.gris,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          _BreakdownCard(parent: parent),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED — Account Step (used by Nomina)
// ═══════════════════════════════════════════════════════════════

class _AccountStep extends StatelessWidget {
  final _CreditoFlowScreenState parent;
  const _AccountStep({super.key, required this.parent});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cuenta destino del deposito',
            style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.gris),
          ),
          const SizedBox(height: 4),
          Text(
            'Selecciona donde recibir los fondos',
            style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed),
          ),
          const SizedBox(height: 16),

          _AccountOption(
            title: 'Cuenta SAYO',
            subtitle: 'CLABE: ${formatClabe(MockUser.clabe)}',
            icon: Icons.account_balance_rounded,
            selected: parent._cuentaSayo,
            color: parent._color,
            recommended: true,
            onTap: () => parent.setState(() => parent._cuentaSayo = true),
          ),
          const SizedBox(height: 8),
          _AccountOption(
            title: 'Cuenta externa',
            subtitle: 'Ingresa CLABE de otro banco',
            icon: Icons.swap_horiz_rounded,
            selected: !parent._cuentaSayo,
            color: parent._color,
            onTap: () => parent.setState(() => parent._cuentaSayo = false),
          ),

          if (!parent._cuentaSayo) ...[
            const SizedBox(height: 14),
            _ClabeInput(parent: parent),
          ],

          const SizedBox(height: 24),

          // Deposit summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: parent._color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: parent._color.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: parent._color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'El deposito se realizara en un plazo de 30 minutos habiles despues de la confirmacion.',
                    style: GoogleFonts.urbanist(fontSize: 12, color: parent._color),
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
// SHARED — Confirm Step
// ═══════════════════════════════════════════════════════════════

class _ConfirmStep extends StatelessWidget {
  final _CreditoFlowScreenState parent;
  final bool isSolicitud;
  const _ConfirmStep({super.key, required this.parent, this.isSolicitud = false});

  @override
  Widget build(BuildContext context) {
    final p = parent.widget.product;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Big amount display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [parent._color.withValues(alpha: 0.1), parent._color.withValues(alpha: 0.03)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: parent._color.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Text(
                  isSolicitud ? 'Monto solicitado' : 'Monto a disponer',
                  style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed),
                ),
                const SizedBox(height: 4),
                Text(
                  formatMoney(parent._monto),
                  style: GoogleFonts.urbanist(fontSize: 36, fontWeight: FontWeight.w800, color: parent._color),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: parent._color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    p.name,
                    style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: parent._color),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Details card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SayoColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SayoColors.beige, width: 0.5),
            ),
            child: Column(
              children: [
                _ConfirmRow('Producto', p.name),
                _ConfirmRow('Monto', formatMoney(parent._monto)),
                _ConfirmRow('Plazo', '${parent._plazo} meses'),
                _ConfirmRow('Tasa anual', '${(p.rate * 100).toStringAsFixed(1)}%'),
                _ConfirmRow('Pago mensual', formatMoney(parent._monthlyPayment)),
                _ConfirmRow('Total a pagar', formatMoney(parent._totalPagar)),
                _ConfirmRow('Total intereses', formatMoney(parent._totalInteres)),
                const Divider(height: 16),
                if (parent._productId == 'simple' && parent._selectedPurpose >= 0)
                  _ConfirmRow('Proposito', MockCreditApplication.purposes[parent._selectedPurpose]),
                _ConfirmRow(
                  'Cuenta destino',
                  parent._cuentaSayo
                      ? 'Cuenta SAYO'
                      : parent._detectedBank?.shortName ?? 'Cuenta externa',
                ),
              ],
            ),
          ),

          // Application warning for Simple
          if (isSolicitud) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SayoColors.blue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SayoColors.blue.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 18, color: SayoColors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tu solicitud sera evaluada en un plazo de 24 a 48 horas habiles. Te notificaremos el resultado.',
                      style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],

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
                    isSolicitud
                        ? 'Autorizo la consulta a mi historial crediticio y acepto los terminos y condiciones del credito.'
                        : 'Acepto los terminos y condiciones, el CAT informativo y el contrato de credito.',
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
// SHARED — Receipt Step
// ═══════════════════════════════════════════════════════════════

class _ReceiptStep extends StatelessWidget {
  final _CreditoFlowScreenState parent;
  final bool isSolicitud;
  const _ReceiptStep({super.key, required this.parent, this.isSolicitud = false});

  @override
  Widget build(BuildContext context) {
    final color = parent._color;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Icon
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSolicitud ? Icons.schedule_rounded : Icons.check_rounded,
              size: 44,
              color: color,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            isSolicitud ? 'Solicitud enviada' : 'Credito aprobado',
            style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: SayoColors.gris),
          ),
          const SizedBox(height: 6),
          Text(
            isSolicitud
                ? 'Tu solicitud esta en evaluacion.\nRecibiras respuesta en 24-48 horas habiles.'
                : 'El deposito se realizara en los proximos\n30 minutos a tu cuenta.',
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed, height: 1.5),
          ),

          const SizedBox(height: 24),

          // Receipt details
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
                _ConfirmRow('Monto', formatMoney(parent._monto)),
                _ConfirmRow('Plazo', '${parent._plazo} meses'),
                _ConfirmRow('Pago mensual', formatMoney(parent._monthlyPayment)),
                _ConfirmRow('Producto', parent.widget.product.name),
                const Divider(height: 16),
                _ConfirmRow(
                  isSolicitud ? 'Folio de solicitud' : 'Referencia',
                  parent._referencia,
                ),
                _ConfirmRow('Fecha', formatDate(DateTime.now())),
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
                  content: Text(isSolicitud ? 'Folio copiado' : 'Referencia copiada'),
                  backgroundColor: color,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy_rounded, size: 16, color: color),
                  const SizedBox(width: 8),
                  Text(
                    'Copiar ${isSolicitud ? 'folio' : 'referencia'}',
                    style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: color),
                  ),
                ],
              ),
            ),
          ),

          if (parent._productId == 'revolvente' && !isSolicitud) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SayoColors.purple.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SayoColors.purple.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: SayoColors.purple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tu linea disponible se actualizara automaticamente. Puedes volver a disponer cuando lo necesites.',
                      style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.purple),
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
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════

class _BreakdownCard extends StatelessWidget {
  final _CreditoFlowScreenState parent;
  const _BreakdownCard({required this.parent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: parent._color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pago mensual', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
                  Text(
                    formatMoney(parent._monthlyPayment),
                    style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: parent._color),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total a pagar', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
                  Text(
                    formatMoney(parent._totalPagar),
                    style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tasa: ${(parent.widget.product.rate * 100).toStringAsFixed(1)}% anual',
                style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed),
              ),
              Text(
                'Interes total: ${formatMoney(parent._totalInteres)}',
                style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Color color;
  final bool recommended;
  final VoidCallback onTap;

  const _AccountOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.color,
    this.recommended = false,
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
                  Row(
                    children: [
                      Text(title, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                      if (recommended) ...[
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
                    ],
                  ),
                  Text(subtitle, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed)),
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

class _ClabeInput extends StatelessWidget {
  final _CreditoFlowScreenState parent;
  const _ClabeInput({required this.parent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: parent._clabeCtrl,
          keyboardType: TextInputType.number,
          maxLength: 18,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w600, color: SayoColors.gris),
          decoration: InputDecoration(
            labelText: 'CLABE interbancaria',
            labelStyle: GoogleFonts.urbanist(color: SayoColors.grisMed),
            counterText: '',
            filled: true,
            fillColor: SayoColors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SayoColors.beige)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SayoColors.beige)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: parent._color, width: 2)),
          ),
        ),
        if (parent._detectedBank != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: SayoColors.green.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SayoColors.green.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, size: 16, color: SayoColors.green),
                const SizedBox(width: 6),
                Text(
                  parent._detectedBank!.shortName,
                  style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.green),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;
  const _MiniInfo(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisMed)),
          Text(value, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.gris)),
        ],
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  const _ConfirmRow(this.label, this.value);

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

class _BottomButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onPressed;

  const _BottomButton({
    required this.label,
    required this.color,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: SayoColors.cream,
        border: Border(top: BorderSide(color: SayoColors.beige.withValues(alpha: 0.5))),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            disabledBackgroundColor: SayoColors.beige,
            foregroundColor: SayoColors.white,
            disabledForegroundColor: SayoColors.grisMed,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Text(
            label,
            style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
