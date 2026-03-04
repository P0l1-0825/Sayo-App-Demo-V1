import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/services/ai_engine.dart';
import '../../shared/data/mock_data.dart';
import '../admin/admin_mock_data.dart';

class FinancialInsightsScreen extends StatelessWidget {
  const FinancialInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = mockTransactionsExtended;
    final categories = SayoAIEngine.categorizeSpending(transactions);
    final insights = SayoAIEngine.generateInsights(transactions);
    final forecast = SayoAIEngine.forecastNextMonth(transactions);

    final totalExpense = transactions.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);

    return Scaffold(
      backgroundColor: SayoColors.cream,
      appBar: AppBar(
        backgroundColor: SayoColors.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: SayoColors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.auto_awesome, color: SayoColors.purple, size: 16),
            ),
            const SizedBox(width: 10),
            Text('Insights Financieros', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Forecast
            _ForecastCard(forecast: forecast),
            const SizedBox(height: 20),

            // AI Insights
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: SayoColors.purple),
                const SizedBox(width: 8),
                Text('Analisis de tu IA', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
              ],
            ),
            const SizedBox(height: 10),
            ...insights.map((insight) => _InsightCard(insight: insight)),
            const SizedBox(height: 20),

            // Spending breakdown
            Text('Desglose de gastos', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SayoColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SayoColors.beige, width: 0.5),
              ),
              child: Column(
                children: [
                  // Bar chart
                  ...categories.map((cat) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(cat.icon, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(cat.name, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris))),
                            Text(formatMoney(cat.amount), style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 44,
                              child: Text(
                                '${(cat.percentOfTotal * 100).toStringAsFixed(0)}%',
                                style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: cat.percentOfTotal,
                            backgroundColor: SayoColors.beige.withValues(alpha: 0.5),
                            valueColor: AlwaysStoppedAnimation(cat.color),
                            minHeight: 6,
                          ),
                        ),
                        if (cat.changeVsLastMonth.abs() > 5)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${cat.changeVsLastMonth > 0 ? '↑' : '↓'} ${cat.changeVsLastMonth.abs().toStringAsFixed(0)}% vs mes anterior',
                                style: GoogleFonts.urbanist(fontSize: 10, color: cat.changeVsLastMonth > 0 ? SayoColors.red : SayoColors.green),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )),
                  const Divider(height: 1, color: SayoColors.beige),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total gastos', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
                      Text(formatMoney(totalExpense), style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w800, color: SayoColors.gris)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Credit Score preview
            Text('Tu score crediticio', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            const SizedBox(height: 10),
            _CreditScorePreview(),
            const SizedBox(height: 20),

            // Product recommendations
            Text('Productos recomendados', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            const SizedBox(height: 10),
            _ProductRecommendations(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS ---

class _ForecastCard extends StatelessWidget {
  final AIMonthlyForecast forecast;
  const _ForecastCard({required this.forecast});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [SayoColors.cafe, SayoColors.cafe.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: Colors.white70),
              const SizedBox(width: 8),
              Text('Pronostico proximo mes', style: GoogleFonts.urbanist(fontSize: 12, color: Colors.white70)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Text('${(forecast.confidence * 100).toStringAsFixed(0)}% confianza', style: GoogleFonts.urbanist(fontSize: 10, color: Colors.white70)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ingresos esperados', style: GoogleFonts.urbanist(fontSize: 10, color: Colors.white60)),
                  const SizedBox(height: 2),
                  Text(formatMoney(forecast.predictedIncome), style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              )),
              Container(width: 1, height: 32, color: Colors.white24),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gastos estimados', style: GoogleFonts.urbanist(fontSize: 10, color: Colors.white60)),
                    const SizedBox(height: 2),
                    Text(formatMoney(forecast.predictedExpense), style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              )),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.savings_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text('Ahorro estimado: ${formatMoney(forecast.predictedSavings)}', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final AIFinancialInsight insight;
  const _InsightCard({required this.insight});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SayoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: insight.color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: insight.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(insight.icon, color: insight.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(insight.title, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.gris)),
              const SizedBox(height: 4),
              Text(insight.description, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
              if (insight.actionLabel != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: insight.color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                  child: Text(insight.actionLabel!, style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: insight.color)),
                ),
              ],
            ],
          )),
        ],
      ),
    );
  }
}

class _CreditScorePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use mock user's corresponding admin data
    final user = mockAdminUsers.firstWhere((u) => u.id == 'USR001');
    final score = SayoAIEngine.calculateCreditScore(user);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SayoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SayoColors.beige, width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72, height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score.scorePercent,
                  backgroundColor: SayoColors.beige.withValues(alpha: 0.5),
                  valueColor: AlwaysStoppedAnimation(score.tierColor),
                  strokeWidth: 6,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${score.score}', style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w800, color: score.tierColor)),
                    Text(score.tier, style: GoogleFonts.urbanist(fontSize: 9, fontWeight: FontWeight.w600, color: score.tierColor)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sayo Credit Score', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
              const SizedBox(height: 6),
              if (score.factors.isNotEmpty) ...[
                ...score.factors.take(3).map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Icon(f.impact >= 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 12, color: f.impact >= 0 ? SayoColors.green : SayoColors.red),
                      const SizedBox(width: 4),
                      Text(f.name, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed)),
                    ],
                  ),
                )),
              ],
            ],
          )),
        ],
      ),
    );
  }
}

class _ProductRecommendations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = mockAdminUsers.firstWhere((u) => u.id == 'USR001');
    final recs = SayoAIEngine.recommendProducts(user);

    return Column(
      children: recs.take(3).map((rec) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SayoColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: rec.color.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: rec.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(rec.icon, color: rec.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(rec.productName, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: rec.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('${rec.matchScore.toStringAsFixed(0)}% match', style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w600, color: rec.color)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(rec.reason, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('Hasta ${formatMoney(rec.suggestedAmount)}', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.gris)),
                    const SizedBox(width: 8),
                    Text('${(rec.suggestedRate * 100).toStringAsFixed(1)}% anual', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed)),
                  ],
                ),
              ],
            )),
          ],
        ),
      )).toList(),
    );
  }
}
