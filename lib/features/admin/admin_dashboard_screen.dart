import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import 'admin_mock_data.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: SayoColors.cafe.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mesa de Control',
                                style: GoogleFonts.urbanist(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Panel Administrativo SAYO',
                                style: GoogleFonts.urbanist(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _AdminHeaderIcon(
                            Icons.notifications_rounded,
                            badge: mockAdminAlerts.length,
                            onTap: () => _showAlerts(context),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => context.go('/dashboard'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: SayoColors.cafe.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text('App', style: GoogleFonts.urbanist(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // KPI Row
                  Row(
                    children: [
                      Expanded(child: _KPICard(
                        label: 'Saldo total',
                        value: formatMoney(AdminSummary.totalBalance),
                        icon: Icons.account_balance_wallet_rounded,
                        color: SayoColors.green,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _KPICard(
                        label: 'Credito colocado',
                        value: formatMoney(AdminSummary.totalCreditUsed),
                        icon: Icons.trending_up_rounded,
                        color: SayoColors.blue,
                      )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _KPICard(
                        label: 'Cobranza mensual',
                        value: formatMoney(AdminSummary.monthlyRevenue),
                        icon: Icons.payments_rounded,
                        color: SayoColors.orange,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _KPICard(
                        label: 'Cartera en riesgo',
                        value: formatMoney(AdminSummary.atRiskAmount),
                        icon: Icons.warning_rounded,
                        color: SayoColors.red,
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Quick nav
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Expanded(child: _NavButton(
                    icon: Icons.people_rounded,
                    label: 'Wallets',
                    subtitle: '${AdminSummary.totalUsers} usuarios',
                    color: SayoColors.blue,
                    onTap: () => context.push('/admin/wallets'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _NavButton(
                    icon: Icons.credit_score_rounded,
                    label: 'Creditos',
                    subtitle: '${AdminSummary.activeCredits} activos',
                    color: SayoColors.green,
                    onTap: () => context.push('/admin/creditos'),
                  )),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  Expanded(child: _NavButton(
                    icon: Icons.verified_user_rounded,
                    label: 'KYC',
                    subtitle: '${mockAdminAlerts.where((a) => a.type == 'info').length} pendientes',
                    color: SayoColors.orange,
                    onTap: () => context.push('/admin/kyc'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _NavButton(
                    icon: Icons.gavel_rounded,
                    label: 'Cobranza',
                    subtitle: '${AdminSummary.overdueCredits} en riesgo',
                    color: SayoColors.red,
                    onTap: () => context.push('/admin/cobranza'),
                  )),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Expanded(child: _NavButton(
                    icon: Icons.bar_chart_rounded,
                    label: 'Reportes',
                    subtitle: 'Metricas',
                    color: SayoColors.purple,
                    onTap: () => context.push('/admin/reportes'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _NavButton(
                    icon: Icons.auto_awesome,
                    label: 'AI Risk',
                    subtitle: 'Scoring & alertas',
                    color: SayoColors.cafe,
                    onTap: () => context.push('/admin/ai-risk'),
                  )),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Expanded(child: _NavButton(
                    icon: Icons.approval_rounded,
                    label: 'Disposiciones',
                    subtitle: 'Autorizaciones',
                    color: SayoColors.green,
                    onTap: () => context.push('/admin/disposiciones'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _NavButton(
                    icon: Icons.credit_card_rounded,
                    label: 'Tarjetas',
                    subtitle: 'Ops & fraude',
                    color: SayoColors.blue,
                    onTap: () => context.push('/admin/tarjetas-ops'),
                  )),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Expanded(child: _NavButton(
                    icon: Icons.sync_alt_rounded,
                    label: 'Conciliacion',
                    subtitle: 'SPEI diario',
                    color: SayoColors.orange,
                    onTap: () => context.push('/admin/conciliacion'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _NavButton(
                    icon: Icons.settings_rounded,
                    label: 'Config',
                    subtitle: 'Sistema',
                    color: SayoColors.grisMed,
                    onTap: () => context.push('/admin/config'),
                  )),
                ],
              ),
            ),
          ),

          // Users overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: _SectionHeader(
                title: 'Resumen de usuarios',
                trailing: '${AdminSummary.activeUsers} activos',
              ),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBadge('Activos', AdminSummary.activeUsers, SayoColors.green),
                    Container(width: 1, height: 36, color: SayoColors.beige),
                    _StatBadge('Pendientes', AdminSummary.pendingUsers, SayoColors.orange),
                    Container(width: 1, height: 36, color: SayoColors.beige),
                    _StatBadge('Suspendidos', AdminSummary.suspendedUsers, SayoColors.red),
                    Container(width: 1, height: 36, color: SayoColors.beige),
                    _StatBadge('Total', AdminSummary.totalUsers, SayoColors.gris),
                  ],
                ),
              ),
            ),
          ),

          // Alerts section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: _SectionHeader(
                title: 'Alertas recientes',
                trailing: '${mockAdminAlerts.length} alertas',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.builder(
              itemCount: mockAdminAlerts.length,
              itemBuilder: (context, i) => _AlertTile(alert: mockAdminAlerts[i]),
            ),
          ),

          // Top wallets
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: _SectionHeader(
                title: 'Wallets con mayor saldo',
                trailing: 'Top 5',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.builder(
              itemCount: _topWallets.length,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => context.push('/admin/wallets/detail', extra: {'userId': _topWallets[i].id}),
                child: _WalletMiniTile(user: _topWallets[i], rank: i + 1),
              ),
            ),
          ),

          // Credits overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: _SectionHeader(
                title: 'Creditos que requieren atencion',
                trailing: '${AdminSummary.overdueCredits} alertas',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.builder(
              itemCount: _attentionCredits.length,
              itemBuilder: (context, i) => _CreditAlertTile(credit: _attentionCredits[i]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  List<AdminWalletUser> get _topWallets {
    final sorted = List<AdminWalletUser>.from(mockAdminUsers)
      ..sort((a, b) => b.balance.compareTo(a.balance));
    return sorted.take(5).toList();
  }

  List<CreditAssignment> get _attentionCredits {
    return mockCreditAssignments
        .where((c) => c.status == 'en_mora' || c.status == 'vencido')
        .toList();
  }

  void _showAlerts(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
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
                    Text('Alertas', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
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
                  itemCount: mockAdminAlerts.length,
                  itemBuilder: (ctx, i) => _AlertTile(alert: mockAdminAlerts[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS ---

class _AdminHeaderIcon extends StatelessWidget {
  final IconData icon;
  final int? badge;
  final VoidCallback onTap;

  const _AdminHeaderIcon(this.icon, {this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          if (badge != null && badge! > 0)
            Positioned(
              top: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: SayoColors.red, shape: BoxShape.circle),
                child: Text('$badge', style: GoogleFonts.urbanist(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

class _KPICard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KPICard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label, style: GoogleFonts.urbanist(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SayoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SayoColors.beige, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                Text(subtitle, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: SayoColors.grisLight, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String trailing;

  const _SectionHeader({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
        Text(trailing, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatBadge(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count', style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
      ],
    );
  }
}

class _AlertTile extends StatelessWidget {
  final AdminAlert alert;

  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SayoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: alert.color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: alert.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(alert.icon, color: alert.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                const SizedBox(height: 2),
                Text(alert.description, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletMiniTile extends StatelessWidget {
  final AdminWalletUser user;
  final int rank;

  const _WalletMiniTile({required this.user, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SayoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SayoColors.beige.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: SayoColors.beige.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text('$rank', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w700, color: SayoColors.grisMed))),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: SayoColors.cafe.withValues(alpha: 0.1),
            child: Text(user.initials, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w700, color: SayoColors.cafe)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
                Text(user.kycLevel, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
              ],
            ),
          ),
          Text(formatMoney(user.balance), style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.green)),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, size: 18, color: SayoColors.grisLight),
        ],
      ),
    );
  }
}

class _CreditAlertTile extends StatelessWidget {
  final CreditAssignment credit;

  const _CreditAlertTile({required this.credit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SayoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: credit.statusColor.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: credit.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(credit.productIcon, color: credit.statusColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(credit.userName, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                Text(credit.productLabel, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatMoney(credit.usedAmount), style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: credit.statusColor)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: credit.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(credit.statusLabel, style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w600, color: credit.statusColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
