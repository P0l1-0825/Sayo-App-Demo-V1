import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/services/tapi_service.dart';
import '../../core/models/tapi_models.dart';

class PagoFlowScreen extends StatefulWidget {
  final String companyId;
  final String companyName;
  final String categoryId;

  const PagoFlowScreen({
    super.key,
    required this.companyId,
    required this.companyName,
    required this.categoryId,
  });

  @override
  State<PagoFlowScreen> createState() => _PagoFlowScreenState();
}

class _PagoFlowScreenState extends State<PagoFlowScreen> {
  final _tapiService = TapiService();
  final _refController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  int _step = 0; // 0=reference, 1=debt, 2=confirm/receipt
  bool _loading = false;
  DebtQuery? _debt;
  PaymentOrder? _payment;
  String? _error;

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  Future<void> _queryDebt() async {
    final ref = _refController.text.trim();
    if (ref.isEmpty) {
      setState(() => _error = 'Ingresa tu numero de referencia');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Simulate network delay for mock
      await Future.delayed(const Duration(milliseconds: 800));
      final debt = await _tapiService.queryDebt(widget.companyId, ref);
      if (!mounted) return;
      setState(() {
        _debt = debt;
        _step = 1;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo consultar la deuda. Verifica tu referencia.';
        _loading = false;
      });
    }
  }

  Future<void> _processPayment() async {
    if (_debt == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 1200));
      final payment = await _tapiService.createPayment(
        widget.companyId,
        _debt!.reference,
        _debt!.amount,
      );
      if (!mounted) return;
      setState(() {
        _payment = payment;
        _step = 2;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al procesar el pago. Intenta de nuevo.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SayoColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  if (_step < 2)
                    IconButton(
                      onPressed: () {
                        if (_step == 0) {
                          context.pop();
                        } else {
                          setState(() {
                            _step = 0;
                            _debt = null;
                            _error = null;
                          });
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  Text(
                    widget.companyName,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: SayoColors.gris,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= _step ? SayoColors.cafe : SayoColors.beige,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _step == 0
                    ? _buildReferenceStep()
                    : _step == 1
                        ? _buildDebtStep()
                        : _buildReceiptStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceStep() {
    return SingleChildScrollView(
      key: const ValueKey('ref'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: SayoColors.cafe.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_rounded, size: 32, color: SayoColors.cafe),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Ingresa tu referencia',
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w800, color: SayoColors.gris),
          ),
          const SizedBox(height: 8),
          Text(
            'Escribe el numero de servicio, cuenta o referencia que aparece en tu recibo de ${widget.companyName}.',
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed, height: 1.5),
          ),
          const SizedBox(height: 32),

          // Input
          Container(
            decoration: BoxDecoration(
              color: SayoColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _error != null ? SayoColors.red : SayoColors.beige),
            ),
            child: TextField(
              controller: _refController,
              keyboardType: TextInputType.text,
              style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w600, color: SayoColors.gris),
              decoration: InputDecoration(
                hintText: 'Ej: 123456789012',
                hintStyle: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.grisLight),
                prefixIcon: const Icon(Icons.tag_rounded, color: SayoColors.cafe, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.red),
            ),
          ],

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _loading ? null : _queryDebt,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: SayoColors.white),
                  )
                : const Text('Consultar deuda'),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtStep() {
    if (_debt == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      key: const ValueKey('debt'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Amount card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: SayoColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SayoColors.beige.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Text(
                  'Monto a pagar',
                  style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed),
                ),
                const SizedBox(height: 8),
                Text(
                  _currencyFormat.format(_debt!.amount),
                  style: GoogleFonts.urbanist(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: SayoColors.gris,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MXN',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: SayoColors.grisMed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SayoColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SayoColors.beige.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                _detailRow('Empresa', _debt!.company),
                const Divider(height: 24, color: SayoColors.divider),
                _detailRow('Referencia', _debt!.reference),
                const Divider(height: 24, color: SayoColors.divider),
                _detailRow('Concepto', _debt!.concept),
                if (_debt!.dueDate != null) ...[
                  const Divider(height: 24, color: SayoColors.divider),
                  _detailRow('Fecha limite', _debt!.dueDate!),
                ],
                const Divider(height: 24, color: SayoColors.divider),
                _detailRow('Comision SAYO', '\$0.00'),
              ],
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.red),
            ),
          ],

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _loading ? null : _processPayment,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: SayoColors.white),
                  )
                : const Text('Confirmar pago'),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'El pago es irrevocable una vez confirmado',
              style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptStep() {
    if (_payment == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      key: const ValueKey('receipt'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Success icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SayoColors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 44, color: SayoColors.green),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Pago exitoso',
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: SayoColors.gris),
          ),
          const SizedBox(height: 4),
          Text(
            _currencyFormat.format(_payment!.amount),
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.w800, color: SayoColors.green),
          ),
          const SizedBox(height: 24),

          // Receipt
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SayoColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SayoColors.beige.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                _detailRow('Orden', _payment!.orderId),
                const Divider(height: 24, color: SayoColors.divider),
                _detailRow('Empresa', widget.companyName),
                const Divider(height: 24, color: SayoColors.divider),
                _detailRow('Referencia', _debt?.reference ?? ''),
                const Divider(height: 24, color: SayoColors.divider),
                _detailRow('Estado', 'Completado'),
                const Divider(height: 24, color: SayoColors.divider),
                _detailRow(
                  'Fecha',
                  DateFormat('dd/MM/yyyy HH:mm').format(_payment!.timestamp),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Volver al inicio'),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Comprobante guardado', style: GoogleFonts.urbanist()),
                    backgroundColor: SayoColors.cafe,
                  ),
                );
              },
              icon: const Icon(Icons.download_rounded, size: 18, color: SayoColors.cafe),
              label: Text(
                'Descargar comprobante',
                style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.cafe),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris),
          ),
        ),
      ],
    );
  }
}
