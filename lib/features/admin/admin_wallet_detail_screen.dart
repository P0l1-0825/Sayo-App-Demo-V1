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
                    onTap: () => _showSnack(context, 'Flujo de asignacion de credito · Proximamente'),
                  ),
                  _ActionButton(
                    icon: Icons.edit_rounded,
                    label: 'Modificar limite de credito',
                    color: SayoColors.blue,
                    onTap: () => _showSnack(context, 'Modificacion de limite · Proximamente'),
                  ),
                  if (user.status == 'activo')
                    _ActionButton(
                      icon: Icons.block_rounded,
                      label: 'Suspender wallet',
                      color: SayoColors.red,
                      onTap: () => _showSnack(context, 'Suspension de cuenta · Proximamente'),
                    ),
                  if (user.status == 'suspendido')
                    _ActionButton(
                      icon: Icons.check_circle_rounded,
                      label: 'Reactivar wallet',
                      color: SayoColors.green,
                      onTap: () => _showSnack(context, 'Reactivacion de cuenta · Proximamente'),
                    ),
                  _ActionButton(
                    icon: Icons.history_rounded,
                    label: 'Ver historial de movimientos',
                    color: SayoColors.cafe,
                    onTap: () => _showSnack(context, 'Historial de movimientos · Proximamente'),
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

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.urbanist()),
        backgroundColor: SayoColors.cafe,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
