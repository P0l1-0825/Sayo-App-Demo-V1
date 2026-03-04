import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  double? _cobroAmount;
  String? _cobroConcept;
  bool _cobroGenerated = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SayoColors.cream,
      appBar: AppBar(
        backgroundColor: SayoColors.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris), onPressed: () => context.pop()),
        title: Text('QR / CoDi', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w500),
          labelColor: SayoColors.cafe,
          unselectedLabelColor: SayoColors.grisLight,
          indicatorColor: SayoColors.cafe,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [Tab(text: 'Cobrar'), Tab(text: 'Pagar')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_cobrarTab(), _pagarTab()],
      ),
    );
  }

  Widget _cobrarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (!_cobroGenerated) ...[
            const SizedBox(height: 20),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: SayoColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.qr_code_rounded, color: SayoColors.green, size: 40),
            ),
            const SizedBox(height: 16),
            Text('Genera tu codigo QR', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
            Text('para recibir un pago', style: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.grisLight)),
            const SizedBox(height: 28),

            // Amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: SayoColors.beige, width: 0.5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Monto a cobrar (opcional)', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.w800, color: SayoColors.gris),
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    prefixStyle: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.w800, color: SayoColors.grisLight),
                    hintText: '0.00',
                    hintStyle: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.w800, color: SayoColors.beige),
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => _cobroAmount = double.tryParse(v),
                ),
                const Divider(height: 1, color: SayoColors.beige),
                const SizedBox(height: 12),
                Text('Concepto (opcional)', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
                const SizedBox(height: 8),
                TextField(
                  style: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.gris),
                  decoration: InputDecoration(
                    hintText: 'Ej: Pago de servicio',
                    hintStyle: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.beige),
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => _cobroConcept = v,
                ),
              ]),
            ),
            const SizedBox(height: 20),

            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () => setState(() => _cobroGenerated = true),
              icon: const Icon(Icons.qr_code_rounded, size: 18),
              label: const Text('Generar QR'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            )),
          ] else ...[
            const SizedBox(height: 16),

            // QR display
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: SayoColors.beige, width: 0.5)),
              child: Column(children: [
                if (_cobroAmount != null && _cobroAmount! > 0)
                  Text(formatMoney(_cobroAmount!), style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.w800, color: SayoColors.green)),
                if (_cobroConcept != null && _cobroConcept!.isNotEmpty)
                  Text(_cobroConcept!, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
                const SizedBox(height: 16),

                // Mock QR
                Container(
                  width: 200, height: 200,
                  decoration: BoxDecoration(color: SayoColors.cream, borderRadius: BorderRadius.circular(16), border: Border.all(color: SayoColors.beige)),
                  child: Stack(children: [
                    Center(child: Icon(Icons.qr_code_2_rounded, size: 160, color: SayoColors.gris.withValues(alpha: 0.8))),
                    Center(child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: SayoColors.cafe, borderRadius: BorderRadius.circular(8)),
                      child: Center(child: Text('S', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white))),
                    )),
                  ]),
                ),
                const SizedBox(height: 16),

                Text('CoDi · Banco de Mexico', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                const SizedBox(height: 8),

                GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: 'SAYO-QR-001-CODI'));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Referencia copiada', style: GoogleFonts.urbanist()), backgroundColor: SayoColors.green, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: SayoColors.cream, borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('REF: SAYO-QR-001', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed)),
                      const SizedBox(width: 6),
                      const Icon(Icons.copy_rounded, size: 12, color: SayoColors.grisLight),
                    ]),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () => _snack('QR compartido'),
                icon: const Icon(Icons.share_rounded, size: 16),
                label: const Text('Compartir'),
              )),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton.icon(
                onPressed: () => setState(() { _cobroGenerated = false; _cobroAmount = null; _cobroConcept = null; }),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Nuevo QR'),
              )),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _pagarTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Camera viewfinder mock
          Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              color: SayoColors.gris.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SayoColors.beige, width: 0.5),
            ),
            child: Stack(children: [
              // Corner indicators
              ..._corners(),
              Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.qr_code_scanner_rounded, size: 60, color: SayoColors.cafe.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text('Apunta la camara al codigo QR', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
                Text('Compatible con CoDi y QR SAYO', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
              ])),
            ]),
          ),
          const SizedBox(height: 20),

          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () => _simulateScan(),
            icon: const Icon(Icons.camera_alt_rounded, size: 18),
            label: const Text('Simular escaneo'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          )),
          const SizedBox(height: 12),

          // Recent QR payments
          Align(alignment: Alignment.centerLeft, child: Text('Pagos QR recientes', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris))),
          const SizedBox(height: 8),
          _RecentQr('Cafe La Colonia', '\$85.00', 'Hoy 09:30', SayoColors.orange),
          _RecentQr('Farmacia Guadalajara', '\$245.50', 'Ayer 18:15', SayoColors.green),
          _RecentQr('Estacionamiento Centro', '\$35.00', '28 Feb', SayoColors.blue),
        ],
      ),
    );
  }

  List<Widget> _corners() {
    const size = 20.0;
    const w = 3.0;
    const color = SayoColors.cafe;
    return [
      Positioned(top: 20, left: 20, child: Container(width: size, height: w, color: color)),
      Positioned(top: 20, left: 20, child: Container(width: w, height: size, color: color)),
      Positioned(top: 20, right: 20, child: Container(width: size, height: w, color: color)),
      Positioned(top: 20, right: 20, child: Container(width: w, height: size, color: color)),
      Positioned(bottom: 20, left: 20, child: Container(width: size, height: w, color: color)),
      Positioned(bottom: 20, left: 20, child: Container(width: w, height: size, color: color)),
      Positioned(bottom: 20, right: 20, child: Container(width: size, height: w, color: color)),
      Positioned(bottom: 20, right: 20, child: Container(width: w, height: size, color: color)),
    ];
  }

  void _simulateScan() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: SayoColors.cream, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Container(width: 56, height: 56, decoration: BoxDecoration(color: SayoColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.check_circle_rounded, color: SayoColors.green, size: 28)),
          const SizedBox(height: 12),
          Text('QR detectado', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
            child: Column(children: [
              _InfoRow('Beneficiario', 'Tienda Demo S.A.'),
              const SizedBox(height: 6),
              _InfoRow('Monto', '\$1,250.00'),
              const SizedBox(height: 6),
              _InfoRow('Concepto', 'Compra en tienda'),
              const SizedBox(height: 6),
              _InfoRow('Tipo', 'CoDi'),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _snack('Pago de \$1,250.00 realizado');
              },
              child: const Text('Pagar'),
            )),
          ]),
        ]),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.urbanist()), backgroundColor: SayoColors.green, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }
}

// --- WIDGETS ---

class _RecentQr extends StatelessWidget {
  final String name, amount, date; final Color color;
  const _RecentQr(this.name, this.amount, this.date, this.color);
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: SayoColors.beige.withValues(alpha: 0.5), width: 0.5)),
    child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.qr_code_rounded, size: 16, color: SayoColors.grisMed)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
        Text(date, style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
      ])),
      Text(amount, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.gris)),
    ]),
  );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);
  @override Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
    Text(value, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
  ]);
}
