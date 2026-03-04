import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/services/ai_engine.dart';
import 'admin_mock_data.dart';

class AdminAIRiskScreen extends StatefulWidget {
  const AdminAIRiskScreen({super.key});

  @override
  State<AdminAIRiskScreen> createState() => _AdminAIRiskScreenState();
}

class _AdminAIRiskScreenState extends State<AdminAIRiskScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final predictions = SayoAIEngine.predictDelinquencies();
    final smartAlerts = SayoAIEngine.generateSmartAlerts();
    final scores = mockAdminUsers.where((u) => u.status != 'pendiente').map((u) => SayoAIEngine.calculateCreditScore(u)).toList()
      ..sort((a, b) => a.score.compareTo(b.score));

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
            Text('AI Risk Dashboard', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Portfolio health overview
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: _PortfolioHealthCard(scores: scores, predictions: predictions),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _Tab('Smart Alerts', Icons.notifications_active_rounded, 0, _tabIndex, smartAlerts.length, () => setState(() => _tabIndex = 0)),
                const SizedBox(width: 8),
                _Tab('Scoring', Icons.score_rounded, 1, _tabIndex, null, () => setState(() => _tabIndex = 1)),
                const SizedBox(width: 8),
                _Tab('Predicciones', Icons.trending_down_rounded, 2, _tabIndex, null, () => setState(() => _tabIndex = 2)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: _tabIndex == 0
                ? _SmartAlertsTab(alerts: smartAlerts)
                : _tabIndex == 1
                    ? _ScoringTab(scores: scores)
                    : _PredictionsTab(predictions: predictions),
          ),
        ],
      ),
    );
  }
}

// --- PORTFOLIO HEALTH ---

class _PortfolioHealthCard extends StatelessWidget {
  final List<AICreditScore> scores;
  final List<AIDelinquencyPrediction> predictions;

  const _PortfolioHealthCard({required this.scores, required this.predictions});

  @override
  Widget build(BuildContext context) {
    final avgScore = scores.isEmpty ? 0 : (scores.fold(0, (s, c) => s + c.score) / scores.length).round();
    final highRisk = predictions.where((p) => p.probability >= 0.40).length;
    final criticalRisk = predictions.where((p) => p.probability >= 0.70).length;

    String healthLabel;
    Color healthColor;
    if (avgScore >= 700 && criticalRisk == 0) {
      healthLabel = 'Saludable';
      healthColor = SayoColors.green;
    } else if (avgScore >= 580 && criticalRisk <= 1) {
      healthLabel = 'Aceptable';
      healthColor = SayoColors.orange;
    } else {
      healthLabel = 'En Riesgo';
      healthColor = SayoColors.red;
    }

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
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Salud del Portafolio', style: GoogleFonts.urbanist(fontSize: 12, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(healthLabel, style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(width: 8),
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(color: healthColor, shape: BoxShape.circle),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    Text('$avgScore', style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('Score Prom.', style: GoogleFonts.urbanist(fontSize: 10, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _HealthMetric('Riesgo critico', '$criticalRisk', criticalRisk > 0 ? SayoColors.red : SayoColors.green),
              Container(width: 1, height: 24, color: Colors.white24),
              _HealthMetric('Riesgo alto', '$highRisk', highRisk > 0 ? SayoColors.orange : SayoColors.green),
              Container(width: 1, height: 24, color: Colors.white24),
              _HealthMetric('Usuarios scored', '${scores.length}', SayoColors.blue),
              Container(width: 1, height: 24, color: Colors.white24),
              _HealthMetric('Mora predicha', '${predictions.where((p) => p.probability >= 0.40).length}', SayoColors.orange),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _HealthMetric(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
            child: Text(value, style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.urbanist(fontSize: 9, color: Colors.white60)),
        ],
      ),
    );
  }
}

// --- TABS ---

class _Tab extends StatelessWidget {
  final String label;
  final IconData icon;
  final int index;
  final int current;
  final int? badge;
  final VoidCallback onTap;
  const _Tab(this.label, this.icon, this.index, this.current, this.badge, this.onTap);
  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? SayoColors.purple.withValues(alpha: 0.1) : SayoColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? SayoColors.purple : SayoColors.beige, width: isActive ? 1.5 : 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isActive ? SayoColors.purple : SayoColors.grisLight),
              const SizedBox(width: 4),
              Text(label, style: GoogleFonts.urbanist(fontSize: 11, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? SayoColors.purple : SayoColors.grisMed)),
              if (badge != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: SayoColors.red, borderRadius: BorderRadius.circular(8)),
                  child: Text('$badge', style: GoogleFonts.urbanist(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// --- SMART ALERTS TAB ---

class _SmartAlertsTab extends StatelessWidget {
  final List<AISmartAlert> alerts;
  const _SmartAlertsTab({required this.alerts});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: alerts.length,
      itemBuilder: (ctx, i) {
        final a = alerts[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SayoColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: a.color.withValues(alpha: 0.3), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: a.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(a.icon, color: a.color, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.title, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                      Text(a.category.toUpperCase(), style: GoogleFonts.urbanist(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: a.color)),
                    ],
                  )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: a.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(a.severity.toUpperCase(), style: GoogleFonts.urbanist(fontSize: 9, fontWeight: FontWeight.w700, color: a.color)),
                      ),
                      const SizedBox(height: 4),
                      Text('${(a.confidence * 100).toStringAsFixed(0)}%', style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(a.description, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: SayoColors.cream, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: SayoColors.purple),
                    const SizedBox(width: 8),
                    Expanded(child: Text(a.recommendedAction, style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: SayoColors.purple))),
                  ],
                ),
              ),
              if (a.userId != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context.push('/admin/wallets/detail', extra: {'userId': a.userId!}),
                  child: Text('Ver wallet →', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: SayoColors.cafe, decoration: TextDecoration.underline)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// --- SCORING TAB ---

class _ScoringTab extends StatelessWidget {
  final List<AICreditScore> scores;
  const _ScoringTab({required this.scores});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: scores.length,
      itemBuilder: (ctx, i) {
        final s = scores[i];
        final user = mockAdminUsers.firstWhere((u) => u.id == s.userId, orElse: () => mockAdminUsers.first);
        return GestureDetector(
          onTap: () => _showScoreDetail(context, s, user),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SayoColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SayoColors.beige, width: 0.5),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48, height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: s.scorePercent,
                        backgroundColor: SayoColors.beige.withValues(alpha: 0.5),
                        valueColor: AlwaysStoppedAnimation(s.tierColor),
                        strokeWidth: 4,
                      ),
                      Text('${s.score}', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w800, color: s.tierColor)),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: s.tierColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(s.tier, style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w600, color: s.tierColor)),
                        ),
                        const SizedBox(width: 6),
                        Text('Default ${(s.defaultProbability * 100).toStringAsFixed(0)}%', style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
                      ],
                    ),
                  ],
                )),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Tasa: ${(s.suggestedRate * 100).toStringAsFixed(1)}%', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: SayoColors.gris)),
                    Text('Limite: ${formatMoney(s.suggestedLimit)}', style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showScoreDetail(BuildContext context, AICreditScore score, AdminWalletUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (ctx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: SayoColors.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),

              // Score header
              Center(child: Column(
                children: [
                  SizedBox(
                    width: 100, height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: score.scorePercent,
                          backgroundColor: SayoColors.beige.withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation(score.tierColor),
                          strokeWidth: 8,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${score.score}', style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.w800, color: score.tierColor)),
                            Text(score.tier, style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: score.tierColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user.name, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
                  Text(user.email, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisLight)),
                ],
              )),
              const SizedBox(height: 20),

              // AI recommendations
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SayoColors.purple.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: SayoColors.purple.withValues(alpha: 0.2), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 16, color: SayoColors.purple),
                        const SizedBox(width: 8),
                        Text('Recomendacion AI', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.purple)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _ScoreRow('Tasa sugerida', '${(score.suggestedRate * 100).toStringAsFixed(1)}% anual'),
                    const SizedBox(height: 6),
                    _ScoreRow('Limite sugerido', formatMoney(score.suggestedLimit)),
                    const SizedBox(height: 6),
                    _ScoreRow('Prob. default', '${(score.defaultProbability * 100).toStringAsFixed(1)}%'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Score factors
              Text('Factores del score', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
              const SizedBox(height: 8),
              ...score.factors.map((f) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SayoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SayoColors.beige, width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (f.impact >= 0 ? SayoColors.green : SayoColors.red).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(f.icon, size: 16, color: f.impact >= 0 ? SayoColors.green : SayoColors.red),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.name, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
                        Text(f.description, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                      ],
                    )),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (f.impact >= 0 ? SayoColors.green : SayoColors.red).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        f.impact >= 0 ? '+${(f.impact * 100).toStringAsFixed(0)}' : '${(f.impact * 100).toStringAsFixed(0)}',
                        style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w700, color: f.impact >= 0 ? SayoColors.green : SayoColors.red),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),

              // Scale
              Text('Escala de scoring', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
                child: Column(
                  children: [
                    _ScaleRow('750-850', 'Excelente', SayoColors.green, score.score >= 750),
                    _ScaleRow('670-749', 'Bueno', SayoColors.blue, score.score >= 670 && score.score < 750),
                    _ScaleRow('580-669', 'Regular', SayoColors.orange, score.score >= 580 && score.score < 670),
                    _ScaleRow('450-579', 'Bajo', const Color(0xFFD97706), score.score >= 450 && score.score < 580),
                    _ScaleRow('300-449', 'Alto Riesgo', SayoColors.red, score.score < 450),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final String value;
  const _ScoreRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
        Text(value, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w700, color: SayoColors.gris)),
      ],
    );
  }
}

class _ScaleRow extends StatelessWidget {
  final String range;
  final String label;
  final Color color;
  final bool isActive;
  const _ScaleRow(this.range, this.label, this.color, this.isActive);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? Border.all(color: color, width: 1) : null,
      ),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 10),
          SizedBox(width: 60, child: Text(range, style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: SayoColors.gris))),
          Expanded(child: Text(label, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed))),
          if (isActive) const Icon(Icons.arrow_back_rounded, size: 14, color: SayoColors.gris),
        ],
      ),
    );
  }
}

// --- PREDICTIONS TAB ---

class _PredictionsTab extends StatelessWidget {
  final List<AIDelinquencyPrediction> predictions;
  const _PredictionsTab({required this.predictions});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: predictions.length,
      itemBuilder: (ctx, i) {
        final p = predictions[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SayoColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.riskColor.withValues(alpha: 0.3), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 44, height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: p.probability,
                          backgroundColor: SayoColors.beige.withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation(p.riskColor),
                          strokeWidth: 4,
                        ),
                        Text('${(p.probability * 100).toStringAsFixed(0)}%', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w800, color: p.riskColor)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.userName, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                      Text(p.creditId, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                    ],
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: p.riskColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(p.riskLevel, style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w700, color: p.riskColor)),
                  ),
                ],
              ),
              if (p.riskFactors.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: p.riskFactors.map((f) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: SayoColors.cream, borderRadius: BorderRadius.circular(6)),
                    child: Text(f, style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisMed)),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: SayoColors.purple.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 12, color: SayoColors.purple),
                    const SizedBox(width: 6),
                    Expanded(child: Text(p.recommendedAction, style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: SayoColors.purple))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
