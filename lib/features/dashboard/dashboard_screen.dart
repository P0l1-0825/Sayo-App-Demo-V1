import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/data/mock_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  colors: [SayoColors.cafe, SayoColors.cafeLight],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                            child: Text(
                              'B',
                              style: GoogleFonts.urbanist(
                                fontWeight: FontWeight.w700,
                                color: SayoColors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hola, ${MockUser.name}',
                                style: GoogleFonts.urbanist(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: SayoColors.white,
                                ),
                              ),
                              Text(
                                MockUser.kycLevel,
                                style: GoogleFonts.urbanist(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _HeaderIcon(
                            Icons.notifications_none_rounded,
                            badge: 3,
                            onTap: () => _showNotifications(context),
                          ),
                          const SizedBox(width: 8),
                          _HeaderIcon(
                            Icons.settings_outlined,
                            onTap: () => context.go('/perfil'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Saldo disponible',
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatMoney(MockUser.balance),
                    style: GoogleFonts.urbanist(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: SayoColors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: MockUser.clabe));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('CLABE copiada', style: GoogleFonts.urbanist()),
                          backgroundColor: SayoColors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'CLABE: ${formatClabe(MockUser.clabe)}',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.copy_rounded, size: 14, color: Colors.white.withValues(alpha: 0.5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: quickActions.map((a) => _QuickActionButton(
                  action: a,
                  onTap: () => _onQuickAction(context, a.label),
                )).toList(),
              ),
            ),
          ),

          // Credit widget
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: GestureDetector(
                onTap: () => context.go('/credito'),
                child: _CreditWidget(),
              ),
            ),
          ),

          // Recent transactions header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Movimientos recientes',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: SayoColors.gris,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showAllTransactions(context),
                    child: Text(
                      'Ver todo',
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: SayoColors.cafe,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Transactions list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.builder(
              itemCount: mockTransactions.length,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => _showTransactionDetail(context, mockTransactions[i]),
                child: _TransactionTile(tx: mockTransactions[i]),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // --- ACTIONS ---

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildSheet(
        title: 'Notificaciones',
        icon: Icons.notifications_rounded,
        iconColor: SayoColors.orange,
        children: [
          _NotifTile('Pago recibido', 'Carlos Mendoza te envio \$15,000', 'Hace 2h', SayoColors.green),
          _NotifTile('Cargo Amazon', 'Compra por \$1,299.00', 'Hace 5h', SayoColors.orange),
          _NotifTile('Recordatorio', 'Tu pago de credito vence en 12 dias', 'Ayer', SayoColors.red),
        ],
      ),
    );
  }

  void _onQuickAction(BuildContext context, String label) {
    switch (label) {
      case 'Transferir':
        _showTransferSheet(context);
      case 'Pagar':
        _showPaySheet(context);
      case 'Cobrar QR':
        _showQRSheet(context);
      case 'Nomina':
        _showNominaSheet(context);
    }
  }

  void _showTransferSheet(BuildContext context) {
    context.push('/transferir');
  }

  void _showPaySheet(BuildContext context) {
    context.push('/servicios');
  }

  void _showQRSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildSheet(
        title: 'Cobrar con QR',
        icon: Icons.qr_code_rounded,
        iconColor: SayoColors.purple,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: SayoColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SayoColors.beige),
              ),
              child: const Center(
                child: Icon(Icons.qr_code_2_rounded, size: 150, color: SayoColors.gris),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Muestra este codigo para recibir pagos',
              style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              MockUser.fullName,
              style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w700, color: SayoColors.gris),
            ),
          ),
        ],
      ),
    );
  }

  void _showNominaSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildSheet(
        title: 'Nomina dispersa',
        icon: Icons.payments_rounded,
        iconColor: SayoColors.orange,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SayoColors.green.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: SayoColors.green, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tu cuenta SAYO esta habilitada para recibir nomina',
                    style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.green, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _NominaInfoRow('CLABE', formatClabe(MockUser.clabe)),
          _NominaInfoRow('Banco', 'Solvendom (SAYO)'),
          _NominaInfoRow('Beneficiario', MockUser.fullName),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: MockUser.clabe));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('CLABE copiada para tu empresa', style: GoogleFonts.urbanist()),
                  backgroundColor: SayoColors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copiar datos para nomina'),
          ),
        ],
      ),
    );
  }

  void _showAllTransactions(BuildContext context) {
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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Todos los movimientos', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close_rounded, color: SayoColors.grisMed),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: mockTransactions.length,
                  itemBuilder: (ctx, i) => GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showTransactionDetail(context, mockTransactions[i]);
                    },
                    child: _TransactionTile(tx: mockTransactions[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, Transaction tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: tx.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(tx.icon, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(height: 12),
            Text(tx.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
            const SizedBox(height: 4),
            Text(tx.subtitle, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
            const SizedBox(height: 16),
            Text(
              '${tx.isIncome ? '+' : '-'}${formatMoney(tx.amount)}',
              style: GoogleFonts.urbanist(fontSize: 32, fontWeight: FontWeight.w800, color: tx.isIncome ? SayoColors.green : SayoColors.gris),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
              child: Column(
                children: [
                  _DetailRow('Fecha', formatDate(tx.date)),
                  const SizedBox(height: 8),
                  _DetailRow('Tipo', tx.isIncome ? 'Ingreso' : 'Cargo'),
                  const SizedBox(height: 8),
                  _DetailRow('Referencia', 'REF${tx.id.padLeft(8, '0')}'),
                  const SizedBox(height: 8),
                  _DetailRow('Estado', 'Completado'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: 'REF${tx.id.padLeft(8, '0')}'));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Referencia copiada', style: GoogleFonts.urbanist()),
                          backgroundColor: SayoColors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copiar ref'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Compartir'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // --- SHEET BUILDER ---

  static Widget _buildSheet({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// --- TRANSFER SHEET (Stateful for input) ---

class _TransferSheet extends StatefulWidget {
  const _TransferSheet();
  @override
  State<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<_TransferSheet> {
  final _clabeCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _conceptoCtrl = TextEditingController();

  @override
  void dispose() {
    _clabeCtrl.dispose();
    _montoCtrl.dispose();
    _conceptoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: SayoColors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.send_rounded, color: SayoColors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Transferir SPEI', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
              ],
            ),
            const SizedBox(height: 20),
            _InputField(controller: _clabeCtrl, label: 'CLABE destino', hint: '18 digitos', keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _InputField(controller: _montoCtrl, label: 'Monto', hint: '\$0.00', keyboardType: TextInputType.number, prefix: '\$ '),
            const SizedBox(height: 12),
            _InputField(controller: _conceptoCtrl, label: 'Concepto', hint: 'Opcional'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Transferencia enviada', style: GoogleFonts.urbanist()),
                    backgroundColor: SayoColors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: const Text('Enviar transferencia'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// --- REUSABLE WIDGETS ---

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final String? prefix;

  const _InputField({required this.controller, required this.label, required this.hint, this.keyboardType, this.prefix});

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
          style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w600, color: SayoColors.gris),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            hintStyle: GoogleFonts.urbanist(fontSize: 15, color: SayoColors.grisLight),
            filled: true,
            fillColor: SayoColors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SayoColors.beige, width: 0.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SayoColors.beige, width: 0.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SayoColors.cafe, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final int? badge;
  final VoidCallback onTap;

  const _HeaderIcon(this.icon, {this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: SayoColors.white, size: 22),
          ),
          if (badge != null)
            Positioned(
              top: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: SayoColors.red, shape: BoxShape.circle),
                child: Text('$badge', style: GoogleFonts.urbanist(fontSize: 9, fontWeight: FontWeight.w700, color: SayoColors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final QuickAction action;
  final VoidCallback onTap;

  const _QuickActionButton({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: action.color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
            child: Icon(action.icon, color: action.color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(action.label, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
        ],
      ),
    );
  }
}

class _CreditWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final usedPercent = MockUser.creditUsed / MockUser.creditLimit;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: SayoColors.beige, width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: SayoColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.trending_up_rounded, color: SayoColors.green, size: 18),
                ),
                const SizedBox(width: 10),
                Text('Linea de credito', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
              ]),
              Text('Ver detalle  >', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.cafe)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: usedPercent, backgroundColor: SayoColors.beige.withValues(alpha: 0.5), valueColor: const AlwaysStoppedAnimation(SayoColors.green), minHeight: 6),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CreditStat('Disponible', formatMoney(MockUser.creditAvailable), SayoColors.green),
              _CreditStat('Usado', formatMoney(MockUser.creditUsed), SayoColors.orange),
              _CreditStat('Limite', formatMoney(MockUser.creditLimit), SayoColors.grisMed),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreditStat extends StatelessWidget {
  final String label; final String value; final Color color;
  const _CreditStat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction tx;
  const _TransactionTile({required this.tx});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige.withValues(alpha: 0.5), width: 0.5)),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: tx.color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(tx.icon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.gris)),
                Text(tx.subtitle, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisLight)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${tx.isIncome ? '+' : '-'}${formatMoney(tx.amount)}', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: tx.isIncome ? SayoColors.green : SayoColors.gris)),
              Text(timeAgo(tx.date), style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
            ],
          ),
        ],
      ),
    );
  }
}

// --- MINI WIDGETS for sheets ---

class _NotifTile extends StatelessWidget {
  final String title, subtitle, time;
  final Color color;
  const _NotifTile(this.title, this.subtitle, this.time, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: SayoColors.beige, width: 0.5)),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.gris)),
              Text(subtitle, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
            ],
          )),
          Text(time, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  const _ServiceTile(this.title, this.subtitle, this.icon, this.color);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pago de $title · Proximamente', style: GoogleFonts.urbanist()),
            backgroundColor: SayoColors.cafe,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: SayoColors.beige, width: 0.5)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.gris)),
              Text(subtitle, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
            ])),
            const Icon(Icons.chevron_right_rounded, size: 20, color: SayoColors.grisLight),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);
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

class _NominaInfoRow extends StatelessWidget {
  final String label, value;
  const _NominaInfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
          Text(value, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
        ],
      ),
    );
  }
}
