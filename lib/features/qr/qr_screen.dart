import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/data/mock_data.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _montoController = TextEditingController();
  final _conceptoController = TextEditingController();
  final _clabeController = TextEditingController();
  final _montoPagoController = TextEditingController();
  final _conceptoPagoController = TextEditingController();
  double? _qrAmount;
  String? _qrConcept;
  bool _qrGenerated = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _montoController.dispose();
    _conceptoController.dispose();
    _clabeController.dispose();
    _montoPagoController.dispose();
    _conceptoPagoController.dispose();
    super.dispose();
  }

  void _generateQR() {
    final amount = double.tryParse(_montoController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ingresa un monto valido', style: GoogleFonts.urbanist(fontWeight: FontWeight.w600)),
          backgroundColor: SayoColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() {
      _qrAmount = amount;
      _qrConcept = _conceptoController.text.isNotEmpty ? _conceptoController.text : 'Cobro SAYO';
      _qrGenerated = true;
    });
  }

  void _showPayConfirmation() {
    final amount = double.tryParse(_montoPagoController.text);
    final clabe = _clabeController.text;
    if (amount == null || amount <= 0 || clabe.length != 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verifica los datos ingresados', style: GoogleFonts.urbanist(fontWeight: FontWeight.w600)),
          backgroundColor: SayoColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: SayoColors.cream,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PayConfirmSheet(
        amount: amount,
        clabe: clabe,
        concept: _conceptoPagoController.text.isNotEmpty ? _conceptoPagoController.text : 'Pago QR',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SayoColors.cream,
      appBar: AppBar(
        backgroundColor: SayoColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('QR / CoDi', style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w800, color: SayoColors.gris)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: SayoColors.cafe,
          indicatorWeight: 3,
          labelColor: SayoColors.cafe,
          unselectedLabelColor: SayoColors.grisMed,
          labelStyle: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Cobrar'),
            Tab(text: 'Pagar'),
            Tab(text: 'CoDi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCobrarTab(),
          _buildPagarTab(),
          _buildCoDiTab(),
        ],
      ),
    );
  }

  // ── Tab 1: Cobrar ──
  Widget _buildCobrarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_qrGenerated) ...[
            Text('Generar QR de cobro', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
            const SizedBox(height: 6),
            Text('Crea un codigo QR para recibir pagos', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w500, color: SayoColors.grisMed)),
            const SizedBox(height: 24),
            _InputField(label: 'Monto a cobrar', hint: '\$0.00', controller: _montoController, keyboardType: TextInputType.number, prefix: '\$ '),
            const SizedBox(height: 16),
            _InputField(label: 'Concepto (opcional)', hint: 'Ej: Comida oficina', controller: _conceptoController),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _generateQR,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SayoColors.purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Generar QR', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: SayoColors.beige.withAlpha(128)),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 20, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: 'sayo://pay?clabe=${MockUser.clabe}&amount=$_qrAmount&concept=$_qrConcept&name=${MockUser.fullName}',
                          version: QrVersions.auto,
                          size: 200,
                          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: SayoColors.cafe),
                          dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: SayoColors.gris),
                        ),
                        const SizedBox(height: 16),
                        Text(MockUser.fullName, style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                        const SizedBox(height: 4),
                        Text(formatMoney(_qrAmount!), style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.w800, color: SayoColors.cafe)),
                        if (_qrConcept != null && _qrConcept!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(_qrConcept!, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w500, color: SayoColors.grisMed)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionChip(label: 'Compartir', icon: Icons.share_rounded, color: SayoColors.blue, onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Compartir QR (demo)', style: GoogleFonts.urbanist(fontWeight: FontWeight.w600)), backgroundColor: SayoColors.cafe, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        );
                      }),
                      const SizedBox(width: 16),
                      _ActionChip(label: 'Nuevo QR', icon: Icons.refresh_rounded, color: SayoColors.green, onTap: () {
                        setState(() {
                          _qrGenerated = false;
                          _montoController.clear();
                          _conceptoController.clear();
                        });
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          Text('Historial de QRs', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
          const SizedBox(height: 12),
          ...MockQR.qrHistory.map((qr) => _QRHistoryTile(qr: qr)),
        ],
      ),
    );
  }

  // ── Tab 2: Pagar ──
  Widget _buildPagarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Camera placeholder
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: SayoColors.gris.withAlpha(20),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SayoColors.beige),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner_rounded, size: 56, color: SayoColors.grisMed.withAlpha(128)),
                const SizedBox(height: 12),
                Text('Escanear QR', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.grisMed)),
                const SizedBox(height: 4),
                Text('Camara no disponible en web', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w500, color: SayoColors.grisLight)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Expanded(child: Divider(color: SayoColors.beige)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('o ingresa los datos', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
                ),
                const Expanded(child: Divider(color: SayoColors.beige)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InputField(label: 'CLABE destino', hint: '18 digitos', controller: _clabeController, keyboardType: TextInputType.number, maxLength: 18),
          const SizedBox(height: 16),
          _InputField(label: 'Monto', hint: '\$0.00', controller: _montoPagoController, keyboardType: TextInputType.number, prefix: '\$ '),
          const SizedBox(height: 16),
          _InputField(label: 'Concepto (opcional)', hint: 'Ej: Pago de servicio', controller: _conceptoPagoController),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _showPayConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: SayoColors.cafe,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Continuar', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 3: CoDi ──
  Widget _buildCoDiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CoDi Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SayoColors.beige.withAlpha(128)),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: SayoColors.green.withAlpha(26),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.verified_rounded, size: 28, color: SayoColors.green),
                ),
                const SizedBox(height: 12),
                Text('CoDi Activo', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.green)),
                const SizedBox(height: 4),
                Text('Registrado: ${MockQR.codiRegistrationDate}', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w500, color: SayoColors.grisMed)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CoDiStat(label: 'Cobros', value: '12'),
                    Container(width: 1, height: 32, color: SayoColors.beige, margin: const EdgeInsets.symmetric(horizontal: 24)),
                    _CoDiStat(label: 'Pagos', value: '8'),
                    Container(width: 1, height: 32, color: SayoColors.beige, margin: const EdgeInsets.symmetric(horizontal: 24)),
                    _CoDiStat(label: 'Total', value: formatMoney(15320)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // What is CoDi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SayoColors.blue.withAlpha(15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SayoColors.blue.withAlpha(51)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 20, color: SayoColors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'CoDi es la plataforma de pagos digitales del Banco de Mexico. Permite cobrar y pagar con codigos QR de forma segura e inmediata.',
                    style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w500, color: SayoColors.blue, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Operaciones recientes', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
          const SizedBox(height: 12),
          ...MockQR.codiOperations.map((op) => _CoDiOperationTile(op: op)),
        ],
      ),
    );
  }
}

// ── Shared Widgets ──

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? prefix;
  final int? maxLength;

  const _InputField({required this.label, required this.hint, required this.controller, this.keyboardType, this.prefix, this.maxLength});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w600),
          inputFormatters: keyboardType == TextInputType.number ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w500, color: SayoColors.grisLight),
            prefixText: prefix,
            prefixStyle: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w600, color: SayoColors.gris),
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SayoColors.beige.withAlpha(128))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SayoColors.beige.withAlpha(128))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SayoColors.cafe, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionChip({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

class _QRHistoryTile extends StatelessWidget {
  final Map<String, dynamic> qr;
  const _QRHistoryTile({required this.qr});

  @override
  Widget build(BuildContext context) {
    final status = qr['status'] as String;
    final statusColor = status == 'Cobrado' ? SayoColors.green : status == 'Pendiente' ? SayoColors.orange : SayoColors.grisLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SayoColors.beige.withAlpha(128)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: SayoColors.purple.withAlpha(20), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.qr_code_rounded, size: 20, color: SayoColors.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(qr['concept'] as String, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                Text(qr['date'] as String, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w500, color: SayoColors.grisMed)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatMoney(qr['amount'] as double), style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withAlpha(26), borderRadius: BorderRadius.circular(6)),
                child: Text(status, style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoDiStat extends StatelessWidget {
  final String label;
  final String value;
  const _CoDiStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w500, color: SayoColors.grisMed)),
      ],
    );
  }
}

class _CoDiOperationTile extends StatelessWidget {
  final Map<String, dynamic> op;
  const _CoDiOperationTile({required this.op});

  @override
  Widget build(BuildContext context) {
    final isCobro = op['type'] == 'Cobro';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SayoColors.beige.withAlpha(128)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isCobro ? SayoColors.green : SayoColors.red).withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCobro ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              size: 20,
              color: isCobro ? SayoColors.green : SayoColors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${op['type']} - ${op['counterpart']}', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                Text(op['date'] as String, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w500, color: SayoColors.grisMed)),
              ],
            ),
          ),
          Text(
            '${isCobro ? '+' : '-'}${formatMoney(op['amount'] as double)}',
            style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w800, color: isCobro ? SayoColors.green : SayoColors.red),
          ),
        ],
      ),
    );
  }
}

class _PayConfirmSheet extends StatelessWidget {
  final double amount;
  final String clabe;
  final String concept;
  const _PayConfirmSheet({required this.amount, required this.clabe, required this.concept});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: SayoColors.blue.withAlpha(26), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.send_rounded, size: 28, color: SayoColors.blue),
          ),
          const SizedBox(height: 16),
          Text('Confirmar pago', style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w800, color: SayoColors.gris)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige.withAlpha(128))),
            child: Column(
              children: [
                _DetailRow(label: 'Monto', value: formatMoney(amount)),
                const SizedBox(height: 10),
                _DetailRow(label: 'CLABE', value: formatClabe(clabe)),
                const SizedBox(height: 10),
                _DetailRow(label: 'Concepto', value: concept),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pago realizado exitosamente', style: GoogleFonts.urbanist(fontWeight: FontWeight.w600)),
                    backgroundColor: SayoColors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SayoColors.cafe,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Confirmar y pagar', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
        Flexible(child: Text(value, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris), textAlign: TextAlign.end)),
      ],
    );
  }
}
