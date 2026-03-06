import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import 'admin_mock_data.dart';

class AdminWalletDetailScreen extends StatelessWidget {
  final String userId;

  const AdminWalletDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final user = mockAdminUsers.firstWhere(
      (u) => u.id == userId,
      orElse: () => mockAdminUsers.first,
    );
    final credits = mockCreditAssignments.where((c) => c.userId == userId).toList();

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
                bottom: 24,
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
                children: [
                  // Nav
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
                        child: Text('Detalle de Wallet', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: user.statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text(user.statusLabel, style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w700, color: user.statusColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // User info
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: SayoColors.cafe.withValues(alpha: 0.3),
                    child: Text(user.initials, style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  const SizedBox(height: 12),
                  Text(user.name, style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(user.email, style: GoogleFonts.urbanist(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
                  const SizedBox(height: 4),
                  Text('${user.kycLevel}  ·  ${user.id}', style: GoogleFonts.urbanist(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
                  const SizedBox(height: 20),

                  // Balance
                  Text('Saldo disponible', style: GoogleFonts.urbanist(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                  const SizedBox(height: 4),
                  Text(
                    formatMoney(user.balance),
                    style: GoogleFonts.urbanist(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                  ),
                ],
              ),
            ),
          ),

          // Account info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text('Informacion de cuenta', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            ),
          ),
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
                  children: [
                    _InfoRow('Nombre', user.name),
                    const Divider(color: SayoColors.beige, height: 16),
                    _InfoRow('Email', user.email),
                    const Divider(color: SayoColors.beige, height: 16),
                    _InfoRow('Telefono', user.phone),
                    const Divider(color: SayoColors.beige, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('CLABE', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
                        Row(
                          children: [
                            Text(formatClabe(user.clabe), style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris, letterSpacing: 0.5)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: user.clabe));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('CLABE copiada', style: GoogleFonts.urbanist()),
                                    backgroundColor: SayoColors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              },
                              child: const Icon(Icons.copy_rounded, size: 14, color: SayoColors.grisLight),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: SayoColors.beige, height: 16),
                    _InfoRow('Registro', formatDate(user.createdAt)),
                    const Divider(color: SayoColors.beige, height: 16),
                    _InfoRow('Ultima actividad', formatDate(user.lastActivity)),
                  ],
                ),
              ),
            ),
          ),

          // Credit overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text('Lineas de credito', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            ),
          ),
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CreditSummary('Limite total', formatMoney(user.creditLimit), SayoColors.grisMed),
                        _CreditSummary('Usado', formatMoney(user.creditUsed), SayoColors.orange),
                        _CreditSummary('Disponible', formatMoney(user.creditAvailable), SayoColors.green),
                      ],
                    ),
                    if (user.creditLimit > 0) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: user.creditUsedPercent,
                          backgroundColor: SayoColors.beige.withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation(
                            user.creditUsedPercent > 0.9 ? SayoColors.red :
                            user.creditUsedPercent > 0.7 ? SayoColors.orange : SayoColors.green,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('${(user.creditUsedPercent * 100).toStringAsFixed(1)}% utilizado', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Credit assignments
          if (credits.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('Creditos asignados (${credits.length})', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.builder(
                itemCount: credits.length,
                itemBuilder: (ctx, i) => _CreditAssignmentCard(credit: credits[i]),
              ),
            ),
          ],

          // Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text('Acciones', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _ActionButton(
                    icon: Icons.add_card_rounded,
                    label: 'Asignar nueva linea de credito',
                    color: SayoColors.green,
                    onTap: () => _showAssignCredit(context, user),
                  ),
                  if (credits.isNotEmpty)
                    _ActionButton(
                      icon: Icons.edit_rounded,
                      label: 'Modificar limite de credito',
                      color: SayoColors.blue,
                      onTap: () => _showModifyLimit(context, credits.first),
                    ),
                  if (user.status == 'activo')
                    _ActionButton(
                      icon: Icons.block_rounded,
                      label: 'Suspender wallet',
                      color: SayoColors.red,
                      onTap: () => _showSuspendWallet(context, user),
                    ),
                  if (user.status == 'suspendido')
                    _ActionButton(
                      icon: Icons.check_circle_rounded,
                      label: 'Reactivar wallet',
                      color: SayoColors.green,
                      onTap: () => _showReactivateWallet(context, user),
                    ),
                  _ActionButton(
                    icon: Icons.history_rounded,
                    label: 'Ver historial de movimientos',
                    color: SayoColors.cafe,
                    onTap: () => context.push('/admin/movimientos', extra: {'userId': user.id, 'userName': user.name}),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  void _showAssignCredit(BuildContext context, AdminWalletUser user) {
    String selectedProduct = 'nomina';
    double selectedLimit = 50000;
    int selectedPlazo = 12;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
                      decoration: BoxDecoration(color: SayoColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.add_card_rounded, color: SayoColors.green, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Asignar linea de credito', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: SayoColors.gris)),
                        Text(user.name, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Text('Producto', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _ProductChip('Nomina', 'nomina', selectedProduct, SayoColors.green, (v) => setModalState(() => selectedProduct = v)),
                    _ProductChip('Adelanto', 'adelanto', selectedProduct, SayoColors.orange, (v) => setModalState(() => selectedProduct = v)),
                    _ProductChip('Simple', 'simple', selectedProduct, SayoColors.blue, (v) => setModalState(() => selectedProduct = v)),
                    _ProductChip('Revolvente', 'revolvente', selectedProduct, SayoColors.purple, (v) => setModalState(() => selectedProduct = v)),
                  ],
                ),
                const SizedBox(height: 16),

                Text('Limite: ${formatMoney(selectedLimit)}', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
                Slider(
                  value: selectedLimit,
                  min: 5000,
                  max: 500000,
                  divisions: 99,
                  activeColor: SayoColors.green,
                  onChanged: (v) => setModalState(() => selectedLimit = v),
                ),
                const SizedBox(height: 8),

                Text('Plazo: $selectedPlazo meses', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
                Slider(
                  value: selectedPlazo.toDouble(),
                  min: 1,
                  max: 48,
                  divisions: 47,
                  activeColor: SayoColors.green,
                  onChanged: (v) => setModalState(() => selectedPlazo = v.round()),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: SayoColors.green.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pago mensual estimado', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
                      Text(formatMoney(selectedLimit / selectedPlazo * 1.15), style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w800, color: SayoColors.green)),
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
                          content: Text('Linea de credito asignada a ${user.name}', style: GoogleFonts.urbanist()),
                          backgroundColor: SayoColors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Confirmar asignacion'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showModifyLimit(BuildContext context, CreditAssignment credit) {
    double newLimit = credit.assignedLimit;

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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: SayoColors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.edit_rounded, color: SayoColors.blue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Modificar limite', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: SayoColors.gris)),
                      Text(credit.productLabel, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: SayoColors.beige, width: 0.5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Limite actual', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                        Text(formatMoney(credit.assignedLimit), style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: SayoColors.grisLight),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Nuevo limite', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                        Text(formatMoney(newLimit), style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: newLimit > credit.assignedLimit ? SayoColors.green : SayoColors.orange)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Slider(
                value: newLimit,
                min: credit.usedAmount > 0 ? credit.usedAmount : 5000,
                max: credit.assignedLimit * 3,
                divisions: 50,
                activeColor: SayoColors.blue,
                onChanged: (v) => setModalState(() => newLimit = v),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatMoney(credit.usedAmount > 0 ? credit.usedAmount : 5000), style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
                  Text(formatMoney(credit.assignedLimit * 3), style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    final change = newLimit > credit.assignedLimit ? 'aumentado' : 'reducido';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Limite $change a ${formatMoney(newLimit)}', style: GoogleFonts.urbanist()),
                        backgroundColor: SayoColors.blue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Aplicar cambio'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuspendWallet(BuildContext context, AdminWalletUser user) {
    String? selectedReason;
    final reasons = ['Fraude detectado', 'Incumplimiento de pago', 'Documentacion invalida', 'Solicitud del usuario', 'Actividad sospechosa'];

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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: SayoColors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.block_rounded, color: SayoColors.red, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Suspender wallet', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: SayoColors.gris)),
                      Text(user.name, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: SayoColors.red.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: SayoColors.red, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Esta accion bloqueara todas las operaciones del usuario', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.red, fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text('Motivo de suspension', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
              const SizedBox(height: 8),
              ...reasons.map((r) => GestureDetector(
                onTap: () => setModalState(() => selectedReason = r),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedReason == r ? SayoColors.red.withValues(alpha: 0.06) : SayoColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selectedReason == r ? SayoColors.red : SayoColors.beige, width: selectedReason == r ? 1.5 : 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(selectedReason == r ? Icons.radio_button_checked : Icons.radio_button_off, size: 18, color: selectedReason == r ? SayoColors.red : SayoColors.grisLight),
                      const SizedBox(width: 10),
                      Text(r, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: selectedReason == r ? FontWeight.w600 : FontWeight.w400, color: SayoColors.gris)),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: selectedReason == null ? null : () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Wallet de ${user.name} suspendida: $selectedReason', style: GoogleFonts.urbanist()),
                        backgroundColor: SayoColors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: SayoColors.red, foregroundColor: Colors.white),
                  icon: const Icon(Icons.block_rounded, size: 18),
                  label: const Text('Confirmar suspension'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showReactivateWallet(BuildContext context, AdminWalletUser user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: SayoColors.cream,
        title: Text('Reactivar wallet', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Se reactivara la wallet de:', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
            const SizedBox(height: 8),
            Text(user.name, style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            const SizedBox(height: 4),
            Text(user.email, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisLight)),
            const SizedBox(height: 12),
            Text('El usuario podra operar nuevamente con su cuenta y lineas de credito.', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.urbanist(fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Wallet de ${user.name} reactivada', style: GoogleFonts.urbanist()),
                  backgroundColor: SayoColors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Reactivar'),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS ---

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

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

class _CreditSummary extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CreditSummary(this.label, this.value, this.color);

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

class _CreditAssignmentCard extends StatelessWidget {
  final CreditAssignment credit;

  const _CreditAssignmentCard({required this.credit});

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
                    Text(credit.productLabel, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                    Text('${credit.id}  ·  ${(credit.interestRate * 100).toStringAsFixed(0)}% anual', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: credit.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(credit.statusLabel, style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w600, color: credit.statusColor)),
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniStat('Limite', formatMoney(credit.assignedLimit), SayoColors.grisMed),
              _MiniStat('Usado', formatMoney(credit.usedAmount), credit.productColor),
              _MiniStat('Pago/mes', formatMoney(credit.monthlyPayment), SayoColors.gris),
              _MiniStat('Pagos', '${credit.paidMonths}/${credit.plazoMonths}', SayoColors.grisMed),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SayoColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: SayoColors.beige, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris))),
            const Icon(Icons.chevron_right_rounded, size: 20, color: SayoColors.grisLight),
          ],
        ),
      ),
    );
  }
}

class _ProductChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Color color;
  final ValueChanged<String> onSelected;

  const _ProductChip(this.label, this.value, this.selected, this.color, this.onSelected);

  @override
  Widget build(BuildContext context) {
    final isActive = value == selected;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : SayoColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? color : SayoColors.beige, width: isActive ? 1.5 : 0.5),
        ),
        child: Text(label, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? color : SayoColors.grisMed)),
      ),
    );
  }
}
