import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/data/mock_data.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedCategory = 'all';

  List<Map<String, dynamic>> get _filteredBenefits {
    if (_selectedCategory == 'all') return MockMarketplace.benefits;
    return MockMarketplace.benefits.where((b) => b['category'] == _selectedCategory).toList();
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
        title: Text('Marketplace', style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w800, color: SayoColors.gris)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, size: 22, color: SayoColors.grisMed),
            onPressed: () => _showRedemptionHistory(context),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildPointsHeader()),
          SliverToBoxAdapter(child: _buildHowItWorks()),
          SliverToBoxAdapter(child: _buildCategoryFilter()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _BenefitCard(
                  benefit: _filteredBenefits[index],
                  onTap: () => _showBenefitDetail(context, _filteredBenefits[index]),
                ),
                childCount: _filteredBenefits.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildPointsHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SayoColors.cafe, SayoColors.cafeLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: SayoColors.cafe.withAlpha(77), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Puntos SAYO', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${MockMarketplace.puntosBalance}', style: GoogleFonts.urbanist(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('pts', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text('Equivalen a', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70)),
                    Text(formatMoney(MockMarketplace.puntosValor), style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_up_rounded, size: 16, color: Colors.white70),
                const SizedBox(width: 8),
                Text('+320 pts acumulados este mes', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SayoColors.orange.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SayoColors.orange.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: SayoColors.orange.withAlpha(38), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.lightbulb_rounded, size: 18, color: SayoColors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w500, color: SayoColors.gris, height: 1.4),
                children: [
                  TextSpan(text: 'Gana 1 punto por cada \$10 ', style: GoogleFonts.urbanist(fontWeight: FontWeight.w700)),
                  const TextSpan(text: 'que gastes con tu tarjeta SAYO. Canjea tus puntos por beneficios exclusivos.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        children: [
          _CategoryChip(label: 'Todos', isSelected: _selectedCategory == 'all', onTap: () => setState(() => _selectedCategory = 'all')),
          ...MockMarketplace.categories.map((cat) => _CategoryChip(
            label: cat['name'] as String,
            isSelected: _selectedCategory == cat['id'],
            onTap: () => setState(() => _selectedCategory = cat['id'] as String),
          )),
        ],
      ),
    );
  }

  void _showBenefitDetail(BuildContext context, Map<String, dynamic> benefit) {
    final points = benefit['points'] as int;
    final canRedeem = MockMarketplace.puntosBalance >= points;
    showModalBottomSheet(
      context: context,
      backgroundColor: SayoColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: (benefit['color'] as Color).withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(benefit['icon'] as IconData, size: 36, color: benefit['color'] as Color),
            ),
            const SizedBox(height: 16),
            Text(benefit['name'] as String, style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: SayoColors.gris)),
            const SizedBox(height: 4),
            Text(benefit['brand'] as String, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige.withAlpha(128))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(benefit['description'] as String, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w500, color: SayoColors.gris, height: 1.5)),
                  const SizedBox(height: 12),
                  const Divider(color: SayoColors.beige),
                  const SizedBox(height: 8),
                  Text('Terminos y condiciones', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w700, color: SayoColors.grisMed)),
                  const SizedBox(height: 4),
                  Text(benefit['terms'] as String, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w500, color: SayoColors.grisLight, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, size: 20, color: SayoColors.orange),
                const SizedBox(width: 6),
                Text('$points puntos', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.orange)),
                if (!canRedeem) ...[
                  const SizedBox(width: 8),
                  Text('(te faltan ${points - MockMarketplace.puntosBalance})', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w500, color: SayoColors.grisLight)),
                ],
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: canRedeem ? () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${benefit['name']} canjeado exitosamente!', style: GoogleFonts.urbanist(fontWeight: FontWeight.w600)),
                      backgroundColor: SayoColors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canRedeem ? SayoColors.cafe : SayoColors.beige,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  canRedeem ? 'Canjear ahora' : 'Puntos insuficientes',
                  style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: canRedeem ? Colors.white : SayoColors.grisMed),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  void _showRedemptionHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SayoColors.cream,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Historial de canjes', style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w800, color: SayoColors.gris)),
            const SizedBox(height: 20),
            ...MockMarketplace.redemptionHistory.map((r) => Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                    decoration: BoxDecoration(color: SayoColors.green.withAlpha(26), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.check_circle_rounded, size: 20, color: SayoColors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['benefit'] as String, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                        Text(r['date'] as String, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w500, color: SayoColors.grisMed)),
                      ],
                    ),
                  ),
                  Text('-${r['points']} pts', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.red)),
                ],
              ),
            )),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? SayoColors.cafe : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? SayoColors.cafe : SayoColors.beige),
        ),
        child: Text(label, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : SayoColors.grisMed)),
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final Map<String, dynamic> benefit;
  final VoidCallback onTap;
  const _BenefitCard({required this.benefit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = benefit['color'] as Color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SayoColors.beige.withAlpha(128)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(benefit['icon'] as IconData, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                benefit['name'] as String,
                style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(benefit['brand'] as String, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w500, color: SayoColors.grisMed)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: SayoColors.orange.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: SayoColors.orange),
                  const SizedBox(width: 4),
                  Text('${benefit['points']} pts', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w700, color: SayoColors.orange)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
