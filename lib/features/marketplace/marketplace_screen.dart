import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';

// --- MODELS ---

class SayoReward {
  final String id, name, description, category;
  final int pointsCost;
  final String icon;
  final Color color;
  final bool featured;

  const SayoReward({required this.id, required this.name, required this.description, required this.category, required this.pointsCost, required this.icon, required this.color, this.featured = false});
}

class SayoPartner {
  final String name, description, discount;
  final Color color;
  const SayoPartner({required this.name, required this.description, required this.discount, required this.color});
}

// --- MOCK DATA ---

const _userPoints = 4750;
const _totalEarned = 12300;

final mockRewards = <SayoReward>[
  SayoReward(id: 'RW001', name: 'Tasa preferencial', description: '0.5% menos en tu proximo credito', category: 'Credito', pointsCost: 2000, icon: '🎯', color: SayoColors.green, featured: true),
  SayoReward(id: 'RW002', name: 'Cashback 5%', description: 'En tu proxima compra con tarjeta SAYO', category: 'Tarjeta', pointsCost: 1500, icon: '💳', color: SayoColors.blue),
  SayoReward(id: 'RW003', name: 'Netflix 1 mes', description: 'Suscripcion Netflix estandar', category: 'Entretenimiento', pointsCost: 3000, icon: '🎬', color: SayoColors.red, featured: true),
  SayoReward(id: 'RW004', name: 'Amazon \$500', description: 'Gift card Amazon Mexico', category: 'Shopping', pointsCost: 5000, icon: '🛒', color: SayoColors.orange),
  SayoReward(id: 'RW005', name: 'Uber \$200', description: 'Credito para viajes Uber', category: 'Transporte', pointsCost: 2000, icon: '🚗', color: SayoColors.gris),
  SayoReward(id: 'RW006', name: 'Spotify 1 mes', description: 'Plan individual Spotify Premium', category: 'Entretenimiento', pointsCost: 2000, icon: '🎵', color: SayoColors.green),
  SayoReward(id: 'RW007', name: 'Sin comision SPEI', description: '10 transferencias SPEI sin costo', category: 'Bancario', pointsCost: 1000, icon: '🏦', color: SayoColors.cafe),
  SayoReward(id: 'RW008', name: 'Starbucks \$150', description: 'Tarjeta de regalo Starbucks', category: 'Cafe', pointsCost: 1500, icon: '☕', color: SayoColors.green),
];

final mockPartners = <SayoPartner>[
  SayoPartner(name: 'Amazon', description: '2x puntos en compras', discount: '2X', color: SayoColors.orange),
  SayoPartner(name: 'Liverpool', description: '3% cashback extra', discount: '3%', color: SayoColors.purple),
  SayoPartner(name: 'Uber', description: '10% descuento', discount: '10%', color: SayoColors.gris),
  SayoPartner(name: 'Netflix', description: 'Paga con puntos', discount: 'PTS', color: SayoColors.red),
];

// --- SCREEN ---

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _category = 'Todos';

  List<SayoReward> get _filtered {
    if (_category == 'Todos') return mockRewards;
    return mockRewards.where((r) => r.category == _category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Todos', ...{...mockRewards.map((r) => r.category)}];

    return Scaffold(
      backgroundColor: SayoColors.cream,
      appBar: AppBar(
        backgroundColor: SayoColors.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris), onPressed: () => context.pop()),
        title: Text('SAYO Marketplace', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
      ),
      body: CustomScrollView(
        slivers: [
          // Points card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [SayoColors.cafe, SayoColors.cafe.withValues(alpha: 0.85)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(children: [
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Tus puntos SAYO', style: GoogleFonts.urbanist(fontSize: 12, color: Colors.white70)),
                      const SizedBox(height: 4),
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('$_userPoints', style: GoogleFonts.urbanist(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(width: 4),
                        Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('pts', style: GoogleFonts.urbanist(fontSize: 14, color: Colors.white60))),
                      ]),
                    ])),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                      child: Column(children: [
                        const Icon(Icons.stars_rounded, color: Colors.white, size: 24),
                        const SizedBox(height: 4),
                        Text('Gold', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Acumulados: $_totalEarned pts', style: GoogleFonts.urbanist(fontSize: 11, color: Colors.white70)),
                      Text('1 pt = \$10 MXN en compras', style: GoogleFonts.urbanist(fontSize: 11, color: Colors.white70)),
                    ]),
                  ),
                ]),
              ),
            ),
          ),

          // Partners
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Aliados SAYO', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: mockPartners.length,
                    itemBuilder: (ctx, i) {
                      final p = mockPartners[i];
                      return Container(
                        width: 130,
                        margin: EdgeInsets.only(right: i < mockPartners.length - 1 ? 8 : 0),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.color.withValues(alpha: 0.2), width: 0.5)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(p.name, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w700, color: SayoColors.gris))),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: p.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text(p.discount, style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w700, color: p.color))),
                          ]),
                          const Spacer(),
                          Text(p.description, style: GoogleFonts.urbanist(fontSize: 9, color: SayoColors.grisLight)),
                        ]),
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),

          // Featured
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text('Destacados', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: mockRewards.where((r) => r.featured).length,
                itemBuilder: (ctx, i) {
                  final r = mockRewards.where((r) => r.featured).toList()[i];
                  return GestureDetector(
                    onTap: () => _showRedeem(r),
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [r.color.withValues(alpha: 0.08), r.color.withValues(alpha: 0.03)]),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: r.color.withValues(alpha: 0.2), width: 0.5),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(r.icon, style: const TextStyle(fontSize: 24)),
                          const Spacer(),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: r.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text('${r.pointsCost} pts', style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w700, color: r.color))),
                        ]),
                        const Spacer(),
                        Text(r.name, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                        Text(r.description, style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ),

          // Category filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(children: [
                Text('Canjear puntos', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                const Spacer(),
                Text('${_filtered.length} disponibles', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (ctx, i) {
                  final c = categories[i];
                  final a = c == _category;
                  return GestureDetector(
                    onTap: () => setState(() => _category = c),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: a ? SayoColors.cafe.withValues(alpha: 0.1) : SayoColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: a ? SayoColors.cafe : SayoColors.beige, width: a ? 1.5 : 0.5)),
                      child: Center(child: Text(c, style: GoogleFonts.urbanist(fontSize: 11, fontWeight: a ? FontWeight.w700 : FontWeight.w500, color: a ? SayoColors.cafe : SayoColors.grisMed))),
                    ),
                  );
                },
              ),
            ),
          ),

          // Rewards grid
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final r = _filtered[i];
                  final canAfford = _userPoints >= r.pointsCost;
                  return GestureDetector(
                    onTap: () => _showRedeem(r),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r.icon, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(r.name, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                        Text(r.description, style: GoogleFonts.urbanist(fontSize: 9, color: SayoColors.grisLight), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const Spacer(),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('${r.pointsCost} pts', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w700, color: canAfford ? r.color : SayoColors.grisLight)),
                          if (!canAfford) Text('Faltan ${r.pointsCost - _userPoints}', style: GoogleFonts.urbanist(fontSize: 9, color: SayoColors.grisLight)),
                        ]),
                      ]),
                    ),
                  );
                },
                childCount: _filtered.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.95),
            ),
          ),
        ],
      ),
    );
  }

  void _showRedeem(SayoReward r) {
    final canAfford = _userPoints >= r.pointsCost;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: SayoColors.cream, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text(r.icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(r.name, style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w800, color: SayoColors.gris)),
          Text(r.description, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Costo', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                Text('${r.pointsCost} puntos', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: r.color)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('Tu saldo', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                Text('$_userPoints pts', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: canAfford ? SayoColors.green : SayoColors.red)),
              ]),
            ]),
          ),
          if (canAfford) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: SayoColors.green.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: SayoColors.green),
                const SizedBox(width: 8),
                Text('Te quedarian ${_userPoints - r.pointsCost} puntos despues del canje', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.green)),
              ]),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: canAfford ? () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${r.name} canjeado exitosamente', style: GoogleFonts.urbanist()), backgroundColor: SayoColors.green, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
            } : null,
            icon: Icon(canAfford ? Icons.check_rounded : Icons.lock_rounded, size: 16),
            label: Text(canAfford ? 'Canjear ${r.pointsCost} pts' : 'Puntos insuficientes'),
          )),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
