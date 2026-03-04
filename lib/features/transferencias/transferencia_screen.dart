import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/data/mock_data.dart';

class TransferenciaScreen extends StatefulWidget {
  const TransferenciaScreen({super.key});

  @override
  State<TransferenciaScreen> createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends State<TransferenciaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _step = 0; // 0=form, 1=confirm, 2=receipt

  // SPEI fields
  final _speiClabeCtrl = TextEditingController();
  final _speiBenefCtrl = TextEditingController();
  final _speiMontoCtrl = TextEditingController();
  final _speiConceptoCtrl = TextEditingController();

  // Tarjeta fields
  final _cardNumCtrl = TextEditingController();
  final _cardBenefCtrl = TextEditingController();
  final _cardMontoCtrl = TextEditingController();
  final _cardConceptoCtrl = TextEditingController();

  // SAYO a SAYO fields
  final _sayoPhoneCtrl = TextEditingController();
  final _sayoMontoCtrl = TextEditingController();
  final _sayoConceptoCtrl = TextEditingController();

  String _selectedBank = '';
  bool _isProcessing = false;
  bool _isFavorite = false;

  final _sayoContacts = [
    {'name': 'Carlos M.', 'phone': '55 1234 5678', 'initial': 'C'},
    {'name': 'Ana Lopez', 'phone': '55 9876 5432', 'initial': 'A'},
    {'name': 'Roberto G.', 'phone': '55 5555 1234', 'initial': 'R'},
  ];

  void _onFieldChange() => setState(() {});

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _step = 0);
      }
    });
    for (final c in [_speiClabeCtrl, _speiMontoCtrl, _cardNumCtrl, _cardMontoCtrl, _sayoPhoneCtrl, _sayoMontoCtrl]) {
      c.addListener(_onFieldChange);
    }
  }

  @override
  void dispose() {
    for (final c in [_speiClabeCtrl, _speiMontoCtrl, _cardNumCtrl, _cardMontoCtrl, _sayoPhoneCtrl, _sayoMontoCtrl]) {
      c.removeListener(_onFieldChange);
    }
    _tabCtrl.dispose();
    _speiClabeCtrl.dispose();
    _speiBenefCtrl.dispose();
    _speiMontoCtrl.dispose();
    _speiConceptoCtrl.dispose();
    _cardNumCtrl.dispose();
    _cardBenefCtrl.dispose();
    _cardMontoCtrl.dispose();
    _cardConceptoCtrl.dispose();
    _sayoPhoneCtrl.dispose();
    _sayoMontoCtrl.dispose();
    _sayoConceptoCtrl.dispose();
    super.dispose();
  }

  void _goToConfirm() => setState(() => _step = 1);

  void _processTransfer() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _step = 2;
    });
  }

  void _resetFlow() {
    setState(() {
      _step = 0;
      _speiClabeCtrl.clear();
      _speiBenefCtrl.clear();
      _speiMontoCtrl.clear();
      _speiConceptoCtrl.clear();
      _cardNumCtrl.clear();
      _cardBenefCtrl.clear();
      _cardMontoCtrl.clear();
      _cardConceptoCtrl.clear();
      _sayoPhoneCtrl.clear();
      _sayoMontoCtrl.clear();
      _sayoConceptoCtrl.clear();
      _selectedBank = '';
      _isFavorite = false;
    });
  }

  String get _currentAmount {
    switch (_tabCtrl.index) {
      case 0: return _speiMontoCtrl.text;
      case 1: return _cardMontoCtrl.text;
      case 2: return _sayoMontoCtrl.text;
      default: return '0';
    }
  }

  String get _currentBeneficiary {
    switch (_tabCtrl.index) {
      case 0: return _speiBenefCtrl.text.isNotEmpty ? _speiBenefCtrl.text : 'Beneficiario SPEI';
      case 1: return _cardBenefCtrl.text.isNotEmpty ? _cardBenefCtrl.text : 'Beneficiario Tarjeta';
      case 2: return 'Usuario SAYO';
      default: return '';
    }
  }

  String get _currentDestination {
    switch (_tabCtrl.index) {
      case 0: return _speiClabeCtrl.text;
      case 1: return _cardNumCtrl.text;
      case 2: return _sayoPhoneCtrl.text;
      default: return '';
    }
  }

  String get _transferType {
    switch (_tabCtrl.index) {
      case 0: return 'SPEI';
      case 1: return 'Tarjeta de Debito';
      case 2: return 'SAYO a SAYO';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SayoColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_step > 0) {
                        setState(() => _step = _step == 2 ? 0 : _step - 1);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(
                      _step == 2 ? Icons.close_rounded : Icons.arrow_back_rounded,
                      color: SayoColors.gris,
                    ),
                  ),
                  Text(
                    _step == 2 ? 'Comprobante' : 'Transferir',
                    style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w800, color: SayoColors.gris),
                  ),
                ],
              ),
            ),

            if (_step == 0) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: SayoColors.beige.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabCtrl,
                    indicator: BoxDecoration(
                      color: SayoColors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: SayoColors.cafe,
                    unselectedLabelColor: SayoColors.grisMed,
                    labelStyle: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w500),
                    tabs: const [
                      Tab(text: 'SPEI', height: 36),
                      Tab(text: 'Tarjeta', height: 36),
                      Tab(text: 'SAYO', height: 36),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [_buildSpeiForm(), _buildCardForm(), _buildSayoForm()],
                ),
              ),
            ] else if (_step == 1) ...[
              Expanded(child: _buildConfirmation()),
            ] else ...[
              Expanded(child: _buildReceipt()),
            ],
          ],
        ),
      ),
    );
  }

  // ── SPEI ──
  Widget _buildSpeiForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BalanceCard(),
          const SizedBox(height: 20),
          _InfoBanner(
            color: SayoColors.blue,
            icon: Icons.info_outline_rounded,
            text: 'Las transferencias SPEI se procesan en segundos, 24/7.',
          ),
          const SizedBox(height: 20),
          _FormField(controller: _speiClabeCtrl, label: 'CLABE interbancaria', hint: '18 digitos', keyboardType: TextInputType.number, maxLength: 18, icon: Icons.account_balance_rounded),
          const SizedBox(height: 14),
          _FormField(controller: _speiBenefCtrl, label: 'Nombre del beneficiario', hint: 'Nombre completo', icon: Icons.person_outline_rounded),
          const SizedBox(height: 14),
          _FormField(controller: _speiMontoCtrl, label: 'Monto', hint: '0.00', keyboardType: TextInputType.number, prefix: '\$ ', icon: Icons.attach_money_rounded),
          const SizedBox(height: 14),
          _FormField(controller: _speiConceptoCtrl, label: 'Concepto (opcional)', hint: 'Pago, transferencia, etc.', icon: Icons.notes_rounded),
          const SizedBox(height: 24),
          _PrimaryButton(
            label: 'Continuar',
            onPressed: _speiClabeCtrl.text.length >= 16 && _speiMontoCtrl.text.isNotEmpty ? _goToConfirm : null,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── TARJETA ──
  Widget _buildCardForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BalanceCard(),
          const SizedBox(height: 20),
          _InfoBanner(
            color: SayoColors.orange,
            icon: Icons.credit_card_rounded,
            text: 'Envia directo a cualquier tarjeta de debito Visa o Mastercard.',
          ),
          const SizedBox(height: 20),
          _FormField(controller: _cardNumCtrl, label: 'Numero de tarjeta', hint: '16 digitos', keyboardType: TextInputType.number, maxLength: 16, icon: Icons.credit_card_rounded),
          const SizedBox(height: 14),
          _FormField(controller: _cardBenefCtrl, label: 'Nombre del titular', hint: 'Como aparece en la tarjeta', icon: Icons.person_outline_rounded),
          const SizedBox(height: 14),
          Text('Banco destino', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ['BBVA', 'Banorte', 'Santander', 'HSBC', 'Banamex', 'Otro'].map((bank) {
              final selected = _selectedBank == bank;
              return GestureDetector(
                onTap: () => setState(() => _selectedBank = bank),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? SayoColors.cafe : SayoColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? SayoColors.cafe : SayoColors.beige, width: selected ? 1.5 : 0.5),
                  ),
                  child: Text(bank, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? SayoColors.white : SayoColors.grisMed)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          _FormField(controller: _cardMontoCtrl, label: 'Monto', hint: '0.00', keyboardType: TextInputType.number, prefix: '\$ ', icon: Icons.attach_money_rounded),
          const SizedBox(height: 14),
          _FormField(controller: _cardConceptoCtrl, label: 'Concepto (opcional)', hint: 'Descripcion del envio', icon: Icons.notes_rounded),
          const SizedBox(height: 24),
          _PrimaryButton(
            label: 'Continuar',
            onPressed: _cardNumCtrl.text.length >= 15 && _cardMontoCtrl.text.isNotEmpty ? _goToConfirm : null,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── SAYO A SAYO ──
  Widget _buildSayoForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BalanceCard(),
          const SizedBox(height: 20),
          _InfoBanner(
            color: SayoColors.purple,
            icon: Icons.bolt_rounded,
            text: 'Envios instantaneos y sin comision entre usuarios SAYO.',
          ),
          const SizedBox(height: 20),
          Text('Contactos frecuentes', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _sayoContacts.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                if (i == _sayoContacts.length) {
                  return Column(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: SayoColors.beige.withValues(alpha: 0.5), shape: BoxShape.circle),
                        child: const Icon(Icons.add_rounded, color: SayoColors.grisMed, size: 22),
                      ),
                      const SizedBox(height: 6),
                      Text('Nuevo', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                    ],
                  );
                }
                final c = _sayoContacts[i];
                final isSelected = _sayoPhoneCtrl.text == c['phone'];
                return GestureDetector(
                  onTap: () => setState(() => _sayoPhoneCtrl.text = c['phone']!),
                  child: Column(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: isSelected ? SayoColors.cafe : SayoColors.cafe.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: SayoColors.cafe, width: 2) : null,
                        ),
                        child: Center(
                          child: Text(c['initial']!, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w700, color: isSelected ? SayoColors.white : SayoColors.cafe)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(c['name']!, style: GoogleFonts.urbanist(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? SayoColors.cafe : SayoColors.grisMed)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _FormField(controller: _sayoPhoneCtrl, label: 'Telefono o tag SAYO', hint: '55 1234 5678 o @usuario', keyboardType: TextInputType.phone, icon: Icons.phone_rounded),
          const SizedBox(height: 14),
          _FormField(controller: _sayoMontoCtrl, label: 'Monto', hint: '0.00', keyboardType: TextInputType.number, prefix: '\$ ', icon: Icons.attach_money_rounded),
          const SizedBox(height: 14),
          _FormField(controller: _sayoConceptoCtrl, label: 'Mensaje (opcional)', hint: 'Para la comida, gracias!', icon: Icons.chat_bubble_outline_rounded),
          const SizedBox(height: 24),
          _PrimaryButton(
            label: 'Enviar a SAYO',
            onPressed: _sayoPhoneCtrl.text.isNotEmpty && _sayoMontoCtrl.text.isNotEmpty ? _goToConfirm : null,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── CONFIRMACION ──
  Widget _buildConfirmation() {
    final amount = double.tryParse(_currentAmount.replaceAll(',', '')) ?? 0;
    final comision = _tabCtrl.index == 2 ? 0.0 : (_tabCtrl.index == 1 ? 7.50 : 0.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [SayoColors.cafe.withValues(alpha: 0.05), SayoColors.cafe.withValues(alpha: 0.02)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SayoColors.beige.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Text('Monto a enviar', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
                const SizedBox(height: 8),
                Text(formatMoney(amount), style: GoogleFonts.urbanist(fontSize: 36, fontWeight: FontWeight.w800, color: SayoColors.cafe)),
                if (comision > 0) ...[
                  const SizedBox(height: 4),
                  Text('+ ${formatMoney(comision)} comision', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.orange)),
                ],
                if (_tabCtrl.index == 2) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: SayoColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('Sin comision', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: SayoColors.green)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: SayoColors.beige, width: 0.5)),
            child: Column(
              children: [
                _ConfirmRow('Tipo', _transferType),
                _ConfirmDivider(),
                _ConfirmRow('Beneficiario', _currentBeneficiary),
                _ConfirmDivider(),
                _ConfirmRow(
                  _tabCtrl.index == 0 ? 'CLABE' : (_tabCtrl.index == 1 ? 'Tarjeta' : 'Telefono'),
                  _formatDest(_currentDestination),
                ),
                if (_selectedBank.isNotEmpty && _tabCtrl.index == 1) ...[
                  _ConfirmDivider(),
                  _ConfirmRow('Banco', _selectedBank),
                ],
                _ConfirmDivider(),
                _ConfirmRow('Concepto', _getConceptText()),
                _ConfirmDivider(),
                _ConfirmRow('Total', formatMoney(amount + comision), isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () => setState(() => _isFavorite = !_isFavorite),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isFavorite ? SayoColors.cafe.withValues(alpha: 0.06) : SayoColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isFavorite ? SayoColors.cafe.withValues(alpha: 0.3) : SayoColors.beige, width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(_isFavorite ? Icons.star_rounded : Icons.star_outline_rounded, color: _isFavorite ? SayoColors.cafe : SayoColors.grisLight, size: 22),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Guardar como favorito', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: _isFavorite ? SayoColors.cafe : SayoColors.grisMed))),
                  Icon(_isFavorite ? Icons.check_circle_rounded : Icons.circle_outlined, color: _isFavorite ? SayoColors.cafe : SayoColors.grisLight, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          _isProcessing
              ? Column(
                  children: [
                    const SizedBox(height: 8),
                    SizedBox(width: 48, height: 48, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(SayoColors.cafe))),
                    const SizedBox(height: 12),
                    Text('Procesando transferencia...', style: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.grisMed)),
                  ],
                )
              : _PrimaryButton(label: 'Confirmar y enviar', onPressed: _processTransfer),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── COMPROBANTE ──
  Widget _buildReceipt() {
    final amount = double.tryParse(_currentAmount.replaceAll(',', '')) ?? 0;
    final now = DateTime.now();
    final refId = 'SAYO${now.millisecondsSinceEpoch.toString().substring(5)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: SayoColors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: SayoColors.green, size: 40),
          ),
          const SizedBox(height: 16),
          Text('Transferencia exitosa', style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: SayoColors.gris)),
          const SizedBox(height: 4),
          Text('${formatDate(now)} a las ${formatTime(now)}', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
          const SizedBox(height: 24),
          Text(formatMoney(amount), style: GoogleFonts.urbanist(fontSize: 38, fontWeight: FontWeight.w800, color: SayoColors.cafe)),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: SayoColors.beige, width: 0.5)),
            child: Column(
              children: [
                _ConfirmRow('Tipo', _transferType),
                _ConfirmDivider(),
                _ConfirmRow('Beneficiario', _currentBeneficiary),
                _ConfirmDivider(),
                _ConfirmRow('Referencia', refId),
                _ConfirmDivider(),
                _ConfirmRow('Estado', 'Completado'),
                _ConfirmDivider(),
                _ConfirmRow('Fecha', '${formatDate(now)} ${formatTime(now)}'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: refId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Referencia copiada', style: GoogleFonts.urbanist()), backgroundColor: SayoColors.green, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copiar ref'),
                  style: OutlinedButton.styleFrom(foregroundColor: SayoColors.cafe, side: const BorderSide(color: SayoColors.beige), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Comprobante compartido', style: GoogleFonts.urbanist()), backgroundColor: SayoColors.cafe, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 16),
                  label: const Text('Compartir'),
                  style: OutlinedButton.styleFrom(foregroundColor: SayoColors.cafe, side: const BorderSide(color: SayoColors.beige), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PrimaryButton(label: 'Nueva transferencia', onPressed: _resetFlow),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Volver al inicio', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _formatDest(String dest) {
    if (dest.length >= 16) return '${dest.substring(0, 4)} •••• •••• ${dest.substring(dest.length - 4)}';
    return dest;
  }

  String _getConceptText() {
    switch (_tabCtrl.index) {
      case 0: return _speiConceptoCtrl.text.isEmpty ? 'Sin concepto' : _speiConceptoCtrl.text;
      case 1: return _cardConceptoCtrl.text.isEmpty ? 'Sin concepto' : _cardConceptoCtrl.text;
      case 2: return _sayoConceptoCtrl.text.isEmpty ? 'Sin mensaje' : _sayoConceptoCtrl.text;
      default: return '';
    }
  }
}

// ── WIDGETS ──

class _BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [SayoColors.cafe, SayoColors.cafeLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saldo disponible', style: GoogleFonts.urbanist(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 4),
          Text(formatMoney(MockUser.balance), style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.w800, color: SayoColors.white)),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  const _InfoBanner({required this.color, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: GoogleFonts.urbanist(fontSize: 12, color: color, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final TextInputType? keyboardType;
  final String? prefix;
  final int? maxLength;
  final IconData icon;

  const _FormField({required this.controller, required this.label, required this.hint, required this.icon, this.keyboardType, this.prefix, this.maxLength});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w600, color: SayoColors.gris),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            prefixIcon: Icon(icon, size: 20, color: SayoColors.grisLight),
            counterText: '',
            hintStyle: GoogleFonts.urbanist(fontSize: 15, color: SayoColors.grisLight),
            filled: true,
            fillColor: SayoColors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SayoColors.beige, width: 0.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SayoColors.beige, width: 0.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SayoColors.cafe, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _PrimaryButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: SayoColors.cafe,
          foregroundColor: SayoColors.white,
          disabledBackgroundColor: SayoColors.beige,
          disabledForegroundColor: SayoColors.grisLight,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  const _ConfirmRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
          Flexible(child: Text(value, style: GoogleFonts.urbanist(fontSize: isBold ? 15 : 13, fontWeight: isBold ? FontWeight.w800 : FontWeight.w600, color: isBold ? SayoColors.cafe : SayoColors.gris), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _ConfirmDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: SayoColors.beige.withValues(alpha: 0.5));
  }
}
