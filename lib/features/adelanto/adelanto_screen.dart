import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/data/mock_data.dart';
import '../../shared/data/spei_participants.dart';

class AdelantoScreen extends StatefulWidget {
  const AdelantoScreen({super.key});

  @override
  State<AdelantoScreen> createState() => _AdelantoScreenState();
}

class _AdelantoScreenState extends State<AdelantoScreen> {
  int _step = 0;
  double _monto = 5000;
  int _plazoIndex = 0; // 0=1 quincena, 1=2 quincenas, 2=1 mes
  bool _cuentaSayo = true;
  bool _aceptoTerminos = false;
  final _clabeCtrl = TextEditingController();
  SpeiParticipant? _detectedBank;
  String _referencia = '';

  static const _plazos = ['1 quincena', '2 quincenas', '1 mes'];
  static const _tasas = [0.035, 0.05, 0.07]; // 3.5%, 5%, 7%

  double get _comision => _monto * _tasas[_plazoIndex];
  double get _totalDescontar => _monto + _comision;
  String get _fechaDescuento {
    switch (_plazoIndex) {
      case 0: return '15 de marzo, 2026';
      case 1: return '31 de marzo, 2026';
      case 2: return '3 de abril, 2026';
      default: return '15 de marzo, 2026';
    }
  }

  @override
  void initState() {
    super.initState();
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
      final bank = SpeiCatalog.fromClabe(text);
      if (bank != _detectedBank) setState(() => _detectedBank = bank);
    } else {
      if (_detectedBank != null) setState(() => _detectedBank = null);
    }
  }

  void _next() {
    if (_step == 2) {
      // Generate mock reference
      final rng = Random();
      _referencia = 'ADN${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}${rng.nextInt(99).toString().padLeft(2, '0')}';
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _reset() {
    setState(() {
      _step = 0;
      _monto = 5000;
      _plazoIndex = 0;
      _cuentaSayo = true;
      _aceptoTerminos = false;
      _clabeCtrl.clear();
      _detectedBank = null;
      _referencia = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: SayoColors.cream,
        body: Column(
          children: [
            _buildHeader(),
            if (_step < 3) _buildProgress(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        color: SayoColors.white,
        border: Border(bottom: BorderSide(color: SayoColors.beige, width: 0.5)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _step == 3 ? () => context.go('/dashboard') : _back,
            icon: Icon(
              _step == 3 ? Icons.close_rounded : Icons.arrow_back_rounded,
              color: SayoColors.gris,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _step == 3 ? 'Comprobante' : 'Adelanto de Nomina',
              style: GoogleFonts.urbanist(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: SayoColors.gris,
              ),
            ),
          ),
          if (_step == 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: SayoColors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Preaprobado',
                style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: SayoColors.orange,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: List.generate(3, (i) {
          final active = i <= _step;
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
              decoration: BoxDecoration(
                color: active ? SayoColors.orange : SayoColors.beige,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _StepElegibilidad(key: const ValueKey(0), state: this);
      case 1: return _StepCuenta(key: const ValueKey(1), state: this);
      case 2: return _StepConfirmacion(key: const ValueKey(2), state: this);
      case 3: return _StepComprobante(key: const ValueKey(3), state: this);
      default: return const SizedBox.shrink();
    }
  }
}

// ─── STEP 0: ELEGIBILIDAD Y MONTO ───

class _StepElegibilidad extends StatelessWidget {
  final _AdelantoScreenState state;
  const _StepElegibilidad({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Eligibility card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [SayoColors.orange.withValues(alpha: 0.08), SayoColors.orange.withValues(alpha: 0.02)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SayoColors.orange.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: SayoColors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.workspace_premium_rounded, color: SayoColors.orange, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(MockNomina.empresa, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                                Text('Nomina quincenal verificada', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed)),
                              ],
                            ),
                          ),
                          const Icon(Icons.verified_rounded, color: SayoColors.green, size: 20),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: _MiniStat('Salario quincenal', formatMoney(MockNomina.salarioQuincenal), SayoColors.gris)),
                          Container(width: 1, height: 30, color: SayoColors.beige),
                          Expanded(child: _MiniStat('Disponible (70%)', formatMoney(MockNomina.montoMaximo), SayoColors.orange)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 13, color: SayoColors.grisMed),
                          const SizedBox(width: 6),
                          Text(
                            'Proximo deposito: ${MockNomina.proximoDeposito}',
                            style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Amount label
                Text('Monto del adelanto', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                const SizedBox(height: 8),

                // Amount display
                Center(
                  child: Text(
                    formatMoney(state._monto),
                    style: GoogleFonts.urbanist(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: SayoColors.orange,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Slider
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: SayoColors.orange,
                    inactiveTrackColor: SayoColors.beige,
                    thumbColor: SayoColors.orange,
                    overlayColor: SayoColors.orange.withValues(alpha: 0.1),
                    trackHeight: 5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: state._monto,
                    min: 1000,
                    max: MockNomina.montoMaximo,
                    divisions: ((MockNomina.montoMaximo - 1000) / 100).round(),
                    onChanged: (v) => state.setState(() => state._monto = (v / 100).round() * 100.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatMoney(1000), style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                      Text(formatMoney(MockNomina.montoMaximo), style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Plazo selector
                Text('Plazo de descuento', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(3, (i) {
                    final selected = state._plazoIndex == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => state.setState(() => state._plazoIndex = i),
                        child: Container(
                          margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? SayoColors.orange : SayoColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? SayoColors.orange : SayoColors.beige,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _AdelantoScreenState._plazos[i],
                                style: GoogleFonts.urbanist(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: selected ? SayoColors.white : SayoColors.gris,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${(_AdelantoScreenState._tasas[i] * 100).toStringAsFixed(1)}%',
                                style: GoogleFonts.urbanist(
                                  fontSize: 11,
                                  color: selected ? Colors.white.withValues(alpha: 0.8) : SayoColors.grisMed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // Breakdown
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SayoColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: SayoColors.beige, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      _BreakdownRow('Monto solicitado', formatMoney(state._monto)),
                      const SizedBox(height: 8),
                      _BreakdownRow(
                        'Comision (${(_AdelantoScreenState._tasas[state._plazoIndex] * 100).toStringAsFixed(1)}%)',
                        formatMoney(state._comision),
                        valueColor: SayoColors.orange,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(height: 1, color: SayoColors.beige),
                      ),
                      _BreakdownRow('Total a descontar', formatMoney(state._totalDescontar), isBold: true),
                      const SizedBox(height: 8),
                      _BreakdownRow('Fecha de descuento', state._fechaDescuento, valueColor: SayoColors.grisMed),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Info banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SayoColors.orange.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SayoColors.orange.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: SayoColors.orange, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'El monto se descuenta automaticamente de tu proxima nomina',
                          style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.orange, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _BottomButton(
          label: 'Continuar',
          enabled: state._monto >= 1000,
          onPressed: state._next,
        ),
      ],
    );
  }
}

// ─── STEP 1: CUENTA DESTINO ───

class _StepCuenta extends StatelessWidget {
  final _AdelantoScreenState state;
  const _StepCuenta({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: SayoColors.orange.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_rounded, color: SayoColors.orange, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        '${formatMoney(state._monto)} · ${_AdelantoScreenState._plazos[state._plazoIndex]}',
                        style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.orange),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text('Donde recibir el adelanto', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                const SizedBox(height: 12),

                // Option: Cuenta SAYO
                _AccountOption(
                  selected: state._cuentaSayo,
                  onTap: () => state.setState(() => state._cuentaSayo = true),
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: SayoColors.cafe,
                  title: 'Cuenta SAYO',
                  subtitle: 'Sin comision extra · Deposito inmediato',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: SayoColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Recomendado', style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w700, color: SayoColors.green)),
                  ),
                ),
                if (state._cuentaSayo) ...[
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.only(left: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SayoColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: SayoColors.beige, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.credit_card_rounded, size: 16, color: SayoColors.grisMed),
                        const SizedBox(width: 8),
                        Text(
                          'CLABE: ${formatClabe(MockUser.clabe)}',
                          style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed, letterSpacing: 0.3),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Option: Cuenta externa
                _AccountOption(
                  selected: !state._cuentaSayo,
                  onTap: () => state.setState(() => state._cuentaSayo = false),
                  icon: Icons.account_balance_rounded,
                  iconColor: SayoColors.blue,
                  title: 'Cuenta externa',
                  subtitle: 'Otro banco · CLABE interbancaria',
                ),
                if (!state._cuentaSayo) ...[
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CLABE destino', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: state._clabeCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 18,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w600, color: SayoColors.gris, letterSpacing: 1),
                          decoration: InputDecoration(
                            hintText: '18 digitos',
                            counterText: '',
                            hintStyle: GoogleFonts.urbanist(fontSize: 15, color: SayoColors.grisLight),
                            filled: true,
                            fillColor: SayoColors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SayoColors.beige, width: 0.5)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SayoColors.beige, width: 0.5)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SayoColors.cafe, width: 1.5)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        if (state._detectedBank != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 14, color: SayoColors.green),
                              const SizedBox(width: 6),
                              Text(
                                '${state._detectedBank!.shortName} (${state._detectedBank!.clave})',
                                style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.green),
                              ),
                            ],
                          ),
                        ] else if (state._clabeCtrl.text.length >= 3) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 14, color: SayoColors.orange),
                              const SizedBox(width: 6),
                              Text(
                                'Institucion no reconocida',
                                style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.orange),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _BottomButton(
          label: 'Continuar',
          enabled: state._cuentaSayo || state._clabeCtrl.text.length == 18,
          onPressed: state._next,
        ),
      ],
    );
  }
}

// ─── STEP 2: CONFIRMACION ───

class _StepConfirmacion extends StatelessWidget {
  final _AdelantoScreenState state;
  const _StepConfirmacion({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final destino = state._cuentaSayo
        ? 'Cuenta SAYO (${formatClabe(MockUser.clabe)})'
        : '${state._detectedBank?.shortName ?? 'Externo'} (${formatClabe(state._clabeCtrl.text)})';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Big amount
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [SayoColors.orange.withValues(alpha: 0.08), SayoColors.orange.withValues(alpha: 0.02)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Monto del adelanto',
                        style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatMoney(state._monto),
                        style: GoogleFonts.urbanist(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: SayoColors.orange,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Detail card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SayoColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: SayoColors.beige, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      _ConfirmRow('Monto del adelanto', formatMoney(state._monto)),
                      _ConfirmDivider(),
                      _ConfirmRow(
                        'Comision (${(_AdelantoScreenState._tasas[state._plazoIndex] * 100).toStringAsFixed(1)}%)',
                        formatMoney(state._comision),
                      ),
                      _ConfirmDivider(),
                      _ConfirmRow('Total a descontar', formatMoney(state._totalDescontar), isBold: true),
                      _ConfirmDivider(),
                      _ConfirmRow('Plazo', _AdelantoScreenState._plazos[state._plazoIndex]),
                      _ConfirmDivider(),
                      _ConfirmRow('Fecha de descuento', state._fechaDescuento),
                      _ConfirmDivider(),
                      _ConfirmRow('Cuenta destino', '', isFullWidth: true),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            destino,
                            style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.gris),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Checkbox
                GestureDetector(
                  onTap: () => state.setState(() => state._aceptoTerminos = !state._aceptoTerminos),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: state._aceptoTerminos ? SayoColors.green.withValues(alpha: 0.04) : SayoColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: state._aceptoTerminos ? SayoColors.green.withValues(alpha: 0.3) : SayoColors.beige,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: state._aceptoTerminos ? SayoColors.green : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: state._aceptoTerminos ? SayoColors.green : SayoColors.grisLight,
                              width: 1.5,
                            ),
                          ),
                          child: state._aceptoTerminos
                              ? const Icon(Icons.check_rounded, size: 16, color: SayoColors.white)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Acepto que el monto total de ${formatMoney(state._totalDescontar)} se descontara de mi proxima nomina',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              color: state._aceptoTerminos ? SayoColors.green : SayoColors.grisMed,
                              fontWeight: state._aceptoTerminos ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _BottomButton(
          label: 'Solicitar Adelanto',
          enabled: state._aceptoTerminos,
          onPressed: state._next,
          icon: Icons.rocket_launch_rounded,
        ),
      ],
    );
  }
}

// ─── STEP 3: COMPROBANTE ───

class _StepComprobante extends StatelessWidget {
  final _AdelantoScreenState state;
  const _StepComprobante({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final destino = state._cuentaSayo
        ? 'Cuenta SAYO'
        : '${state._detectedBank?.shortName ?? 'Externo'} (${state._clabeCtrl.text})';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Success icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: SayoColors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, size: 44, color: SayoColors.green),
          ),
          const SizedBox(height: 16),
          Text(
            'Adelanto aprobado',
            style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: SayoColors.gris),
          ),
          const SizedBox(height: 6),
          Text(
            'Se depositara en los proximos 15 minutos',
            style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed),
          ),

          const SizedBox(height: 24),

          // Receipt card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SayoColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SayoColors.beige, width: 0.5),
            ),
            child: Column(
              children: [
                _ConfirmRow('Referencia', state._referencia),
                _ConfirmDivider(),
                _ConfirmRow('Monto', formatMoney(state._monto)),
                _ConfirmDivider(),
                _ConfirmRow('Comision', formatMoney(state._comision)),
                _ConfirmDivider(),
                _ConfirmRow('Total a descontar', formatMoney(state._totalDescontar), isBold: true),
                _ConfirmDivider(),
                _ConfirmRow('Cuenta destino', destino),
                _ConfirmDivider(),
                _ConfirmRow('Deposito estimado', '15 minutos'),
                _ConfirmDivider(),
                _ConfirmRow('Descuento nomina', state._fechaDescuento),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: state._referencia));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Referencia copiada', style: GoogleFonts.urbanist()),
                        backgroundColor: SayoColors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copiar ref'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SayoColors.cafe,
                    side: const BorderSide(color: SayoColors.beige),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Compartir comprobante...', style: GoogleFonts.urbanist()),
                        backgroundColor: SayoColors.cafe,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 16),
                  label: const Text('Compartir'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SayoColors.cafe,
                    side: const BorderSide(color: SayoColors.beige),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Primary CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SayoColors.cafe,
                foregroundColor: SayoColors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                textStyle: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              child: const Text('Volver al inicio'),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── SHARED WIDGETS ───

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color valueColor;
  const _MiniStat(this.label, this.value, this.valueColor);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w800, color: valueColor)),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool isBold;
  const _BreakdownRow(this.label, this.value, {this.valueColor, this.isBold = false});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.urbanist(fontSize: 13, color: isBold ? SayoColors.gris : SayoColors.grisMed, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500)),
        Text(value, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: isBold ? FontWeight.w800 : FontWeight.w600, color: valueColor ?? SayoColors.gris)),
      ],
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  final bool isFullWidth;
  const _ConfirmRow(this.label, this.value, {this.isBold = false, this.isFullWidth = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: isFullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
          if (!isFullWidth)
            Flexible(
              child: Text(
                value,
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                  color: SayoColors.gris,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}

class _ConfirmDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 0.5, color: SayoColors.beige.withValues(alpha: 0.6));
  }
}

class _AccountOption extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final Widget? trailing;

  const _AccountOption({
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? SayoColors.cafe.withValues(alpha: 0.03) : SayoColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? SayoColors.cafe : SayoColors.beige,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? SayoColors.cafe : SayoColors.grisLight,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: SayoColors.cafe,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                      if (trailing != null) ...[const SizedBox(width: 8), trailing!],
                    ],
                  ),
                  Text(subtitle, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  final IconData? icon;

  const _BottomButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: SayoColors.white,
        border: const Border(top: BorderSide(color: SayoColors.beige, width: 0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: SayoColors.orange,
            foregroundColor: SayoColors.white,
            disabledBackgroundColor: SayoColors.beige,
            disabledForegroundColor: SayoColors.grisLight,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
            textStyle: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          child: icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                    Text(label),
                  ],
                )
              : Text(label),
        ),
      ),
    );
  }
}
