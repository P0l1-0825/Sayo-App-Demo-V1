import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/sayo_colors.dart';
import '../../shared/data/mock_data.dart';
import '../../features/admin/admin_mock_data.dart';

// ==========================================================
// SAYO AI ENGINE
// Motor de inteligencia artificial para scoring crediticio,
// prediccion de morosidad, insights financieros y
// recomendaciones de productos.
// ==========================================================

// --- CREDIT SCORE ---

class AICreditScore {
  final String userId;
  final int score; // 300-850
  final String tier; // Excelente, Bueno, Regular, Bajo, Alto Riesgo
  final Color tierColor;
  final double defaultProbability; // 0.0 - 1.0
  final double suggestedRate;
  final double suggestedLimit;
  final List<AIScoreFactor> factors;
  final DateTime calculatedAt;

  const AICreditScore({
    required this.userId,
    required this.score,
    required this.tier,
    required this.tierColor,
    required this.defaultProbability,
    required this.suggestedRate,
    required this.suggestedLimit,
    required this.factors,
    required this.calculatedAt,
  });

  double get scorePercent => (score - 300) / 550; // normalized 0-1
}

class AIScoreFactor {
  final String name;
  final String description;
  final double impact; // -1.0 to 1.0 (negative = hurts score)
  final IconData icon;

  const AIScoreFactor({
    required this.name,
    required this.description,
    required this.impact,
    required this.icon,
  });
}

// --- DELINQUENCY PREDICTION ---

class AIDelinquencyPrediction {
  final String userId;
  final String userName;
  final String creditId;
  final double probability; // 0-1
  final String riskLevel; // Bajo, Medio, Alto, Critico
  final Color riskColor;
  final List<String> riskFactors;
  final String recommendedAction;
  final DateTime predictedFor; // when the default might happen

  const AIDelinquencyPrediction({
    required this.userId,
    required this.userName,
    required this.creditId,
    required this.probability,
    required this.riskLevel,
    required this.riskColor,
    required this.riskFactors,
    required this.recommendedAction,
    required this.predictedFor,
  });
}

// --- SPENDING INSIGHTS ---

class AISpendingCategory {
  final String name;
  final String icon;
  final double amount;
  final double percentOfTotal;
  final Color color;
  final double changeVsLastMonth; // percentage change

  const AISpendingCategory({
    required this.name,
    required this.icon,
    required this.amount,
    required this.percentOfTotal,
    required this.color,
    required this.changeVsLastMonth,
  });
}

class AIFinancialInsight {
  final String title;
  final String description;
  final String type; // saving, warning, tip, achievement
  final IconData icon;
  final Color color;
  final String? actionLabel;

  const AIFinancialInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    required this.color,
    this.actionLabel,
  });
}

class AIMonthlyForecast {
  final double predictedIncome;
  final double predictedExpense;
  final double predictedSavings;
  final double confidence;

  const AIMonthlyForecast({
    required this.predictedIncome,
    required this.predictedExpense,
    required this.predictedSavings,
    required this.confidence,
  });
}

// --- PRODUCT RECOMMENDATION ---

class AIProductRecommendation {
  final String productType;
  final String productName;
  final double matchScore; // 0-100
  final String reason;
  final double suggestedAmount;
  final double suggestedRate;
  final int suggestedPlazo;
  final double estimatedPayment;
  final IconData icon;
  final Color color;

  const AIProductRecommendation({
    required this.productType,
    required this.productName,
    required this.matchScore,
    required this.reason,
    required this.suggestedAmount,
    required this.suggestedRate,
    required this.suggestedPlazo,
    required this.estimatedPayment,
    required this.icon,
    required this.color,
  });
}

// --- SMART ALERT ---

class AISmartAlert {
  final String id;
  final String title;
  final String description;
  final String severity; // critical, high, medium, low
  final String category; // delinquency, fraud, utilization, liquidity, kyc
  final Color color;
  final IconData icon;
  final String recommendedAction;
  final double confidence;
  final DateTime generatedAt;
  final String? userId;

  const AISmartAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
    required this.color,
    required this.icon,
    required this.recommendedAction,
    required this.confidence,
    required this.generatedAt,
    this.userId,
  });
}

// ==========================================================
// AI ENGINE - Scoring & Predictions
// ==========================================================

class SayoAIEngine {
  // --- CREDIT SCORE CALCULATION ---
  static AICreditScore calculateCreditScore(AdminWalletUser user) {
    final credits = mockCreditAssignments.where((c) => c.userId == user.id).toList();

    double score = 550; // base

    // 1. Payment history (35% weight) - most important
    double paymentScore = 0;
    for (final c in credits) {
      if (c.status == 'liquidado') {
        paymentScore += 100;
      } else if (c.status == 'vigente') {
        final onTimeRatio = c.plazoMonths > 0 ? c.paidMonths / c.plazoMonths : 0;
        paymentScore += 80 * onTimeRatio + 20;
      } else if (c.status == 'en_mora') {
        paymentScore -= 40;
      } else if (c.status == 'vencido') {
        paymentScore -= 80;
      }
    }
    if (credits.isNotEmpty) paymentScore /= credits.length;
    score += paymentScore * 0.35 * 3;

    // 2. Credit utilization (30% weight)
    final utilization = user.creditUsedPercent;
    double utilizationScore;
    if (utilization < 0.10) {
      utilizationScore = 90;
    } else if (utilization < 0.30) {
      utilizationScore = 100; // sweet spot
    } else if (utilization < 0.50) {
      utilizationScore = 80;
    } else if (utilization < 0.70) {
      utilizationScore = 50;
    } else if (utilization < 0.90) {
      utilizationScore = 20;
    } else {
      utilizationScore = -30;
    }
    score += utilizationScore * 0.30 * 3;

    // 3. Account age & history (15%)
    final accountAge = DateTime.now().difference(user.createdAt).inDays;
    double ageScore;
    if (accountAge > 365) {
      ageScore = 80;
    } else if (accountAge > 180) {
      ageScore = 60;
    } else if (accountAge > 90) {
      ageScore = 30;
    } else {
      ageScore = 10;
    }
    score += ageScore * 0.15 * 3;

    // 4. KYC level (10%)
    double kycScore;
    switch (user.kycLevel) {
      case 'Nivel 3':
        kycScore = 100;
        break;
      case 'Nivel 2':
        kycScore = 60;
        break;
      default:
        kycScore = 20;
    }
    score += kycScore * 0.10 * 3;

    // 5. Balance health (10%)
    double balanceScore;
    if (user.balance > 50000) {
      balanceScore = 90;
    } else if (user.balance > 20000) {
      balanceScore = 70;
    } else if (user.balance > 5000) {
      balanceScore = 40;
    } else {
      balanceScore = 10;
    }
    score += balanceScore * 0.10 * 3;

    // Clamp
    score = score.clamp(300, 850).toDouble();
    final intScore = score.round();

    // Tier
    String tier;
    Color tierColor;
    if (intScore >= 750) {
      tier = 'Excelente';
      tierColor = SayoColors.green;
    } else if (intScore >= 670) {
      tier = 'Bueno';
      tierColor = SayoColors.blue;
    } else if (intScore >= 580) {
      tier = 'Regular';
      tierColor = SayoColors.orange;
    } else if (intScore >= 450) {
      tier = 'Bajo';
      tierColor = const Color(0xFFD97706);
    } else {
      tier = 'Alto Riesgo';
      tierColor = SayoColors.red;
    }

    // Default probability
    final defaultProb = (1.0 - (intScore - 300) / 550.0).clamp(0.01, 0.95);

    // Suggested rate (risk-based pricing)
    final baseRate = 0.12;
    final riskPremium = defaultProb * 0.15;
    final suggestedRate = (baseRate + riskPremium).clamp(0.11, 0.28);

    // Suggested limit
    final suggestedLimit = user.balance * 3 * (intScore / 850);

    // Factors
    final factors = <AIScoreFactor>[];
    if (credits.any((c) => c.status == 'vigente')) {
      factors.add(const AIScoreFactor(name: 'Pagos al corriente', description: 'Historial de pagos a tiempo', impact: 0.8, icon: Icons.check_circle_rounded));
    }
    if (credits.any((c) => c.status == 'en_mora' || c.status == 'vencido')) {
      factors.add(const AIScoreFactor(name: 'Pagos atrasados', description: 'Creditos en mora o vencidos', impact: -0.7, icon: Icons.warning_rounded));
    }
    if (utilization > 0.80) {
      factors.add(const AIScoreFactor(name: 'Alta utilizacion', description: 'Uso de credito superior al 80%', impact: -0.5, icon: Icons.trending_up_rounded));
    } else if (utilization > 0 && utilization < 0.30) {
      factors.add(const AIScoreFactor(name: 'Baja utilizacion', description: 'Uso saludable de linea de credito', impact: 0.6, icon: Icons.thumb_up_rounded));
    }
    if (user.kycLevel == 'Nivel 3') {
      factors.add(const AIScoreFactor(name: 'KYC completo', description: 'Verificacion de identidad nivel 3', impact: 0.4, icon: Icons.verified_user_rounded));
    }
    if (accountAge > 365) {
      factors.add(const AIScoreFactor(name: 'Antigüedad', description: 'Cuenta con mas de 1 año', impact: 0.5, icon: Icons.history_rounded));
    }
    if (user.balance > 30000) {
      factors.add(const AIScoreFactor(name: 'Saldo saludable', description: 'Balance positivo y estable', impact: 0.3, icon: Icons.account_balance_wallet_rounded));
    }
    if (user.balance < 5000 && credits.any((c) => c.status != 'liquidado')) {
      factors.add(const AIScoreFactor(name: 'Liquidez baja', description: 'Saldo insuficiente para obligaciones', impact: -0.4, icon: Icons.account_balance_rounded));
    }

    return AICreditScore(
      userId: user.id,
      score: intScore,
      tier: tier,
      tierColor: tierColor,
      defaultProbability: defaultProb,
      suggestedRate: suggestedRate,
      suggestedLimit: suggestedLimit,
      factors: factors,
      calculatedAt: DateTime.now(),
    );
  }

  // --- DELINQUENCY PREDICTIONS ---
  static List<AIDelinquencyPrediction> predictDelinquencies() {
    final predictions = <AIDelinquencyPrediction>[];

    for (final credit in mockCreditAssignments) {
      if (credit.status == 'liquidado') continue;

      final user = mockAdminUsers.firstWhere((u) => u.id == credit.userId, orElse: () => mockAdminUsers.first);

      double probability = 0.05; // base

      // Payment history
      if (credit.status == 'en_mora') probability += 0.45;
      if (credit.status == 'vencido') probability += 0.65;

      // Utilization
      final util = credit.usedPercent;
      if (util > 0.90) probability += 0.15;
      else if (util > 0.70) probability += 0.08;

      // Balance vs obligations
      if (user.balance < credit.monthlyPayment * 2) probability += 0.15;
      if (user.balance < credit.monthlyPayment) probability += 0.20;

      // Inactivity
      final daysSinceActive = DateTime.now().difference(user.lastActivity).inDays;
      if (daysSinceActive > 30) probability += 0.12;
      if (daysSinceActive > 60) probability += 0.10;

      // KYC
      if (user.kycLevel == 'Nivel 1') probability += 0.05;

      probability = probability.clamp(0.01, 0.99);

      String riskLevel;
      Color riskColor;
      if (probability >= 0.70) {
        riskLevel = 'Critico';
        riskColor = SayoColors.red;
      } else if (probability >= 0.40) {
        riskLevel = 'Alto';
        riskColor = SayoColors.orange;
      } else if (probability >= 0.20) {
        riskLevel = 'Medio';
        riskColor = const Color(0xFFD97706);
      } else {
        riskLevel = 'Bajo';
        riskColor = SayoColors.green;
      }

      final riskFactors = <String>[];
      if (credit.status == 'en_mora') riskFactors.add('Credito en mora');
      if (credit.status == 'vencido') riskFactors.add('Credito vencido');
      if (util > 0.80) riskFactors.add('Utilizacion ${(util * 100).toStringAsFixed(0)}%');
      if (user.balance < credit.monthlyPayment * 2) riskFactors.add('Saldo insuficiente para 2 pagos');
      if (daysSinceActive > 30) riskFactors.add('$daysSinceActive dias sin actividad');

      String action;
      if (probability >= 0.70) {
        action = 'Contacto inmediato + plan de pago';
      } else if (probability >= 0.40) {
        action = 'Enviar aviso preventivo';
      } else if (probability >= 0.20) {
        action = 'Monitoreo cercano';
      } else {
        action = 'Sin accion requerida';
      }

      predictions.add(AIDelinquencyPrediction(
        userId: user.id,
        userName: user.name,
        creditId: credit.id,
        probability: probability,
        riskLevel: riskLevel,
        riskColor: riskColor,
        riskFactors: riskFactors,
        recommendedAction: action,
        predictedFor: DateTime.now().add(const Duration(days: 30)),
      ));
    }

    predictions.sort((a, b) => b.probability.compareTo(a.probability));
    return predictions;
  }

  // --- SPENDING CATEGORIZATION ---
  static List<AISpendingCategory> categorizeSpending(List<Transaction> transactions) {
    final categoryMap = <String, _CategoryAccum>{};

    for (final tx in transactions.where((t) => !t.isIncome)) {
      final category = _classifyTransaction(tx);
      categoryMap.putIfAbsent(category.name, () => _CategoryAccum(category.name, category.icon, category.color, 0));
      categoryMap[category.name] = _CategoryAccum(category.name, category.icon, category.color, categoryMap[category.name]!.amount + tx.amount);
    }

    final total = categoryMap.values.fold(0.0, (s, c) => s + c.amount);
    final categories = categoryMap.values.map((c) => AISpendingCategory(
      name: c.name,
      icon: c.icon,
      amount: c.amount,
      percentOfTotal: total > 0 ? c.amount / total : 0,
      color: c.color,
      changeVsLastMonth: (Random(c.name.hashCode).nextDouble() * 40 - 15), // simulated
    )).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return categories;
  }

  static _TxCategory _classifyTransaction(Transaction tx) {
    final title = tx.title.toLowerCase();

    if (title.contains('spei') && !tx.isIncome) return _TxCategory('Transferencias', '↑', SayoColors.red);
    if (title.contains('nomina') || title.contains('salario')) return _TxCategory('Nomina', '💰', SayoColors.green);
    if (title.contains('amazon') || title.contains('liverpool') || title.contains('soriana')) return _TxCategory('Compras', '🛒', SayoColors.orange);
    if (title.contains('cfe') || title.contains('telmex') || title.contains('gas')) return _TxCategory('Servicios', '⚡', SayoColors.blue);
    if (title.contains('netflix') || title.contains('spotify')) return _TxCategory('Suscripciones', '🎬', SayoColors.purple);
    if (title.contains('uber eats') || title.contains('rappi')) return _TxCategory('Comida', '🍔', SayoColors.orange);
    if (title.contains('uber') || title.contains('didi')) return _TxCategory('Transporte', '🚗', SayoColors.gris);
    if (title.contains('oxxo')) return _TxCategory('Tienda', '🏪', SayoColors.orange);
    if (title.contains('credito') || title.contains('pago credito')) return _TxCategory('Credito', '🏦', SayoColors.cafe);

    return _TxCategory('Otros', '📦', SayoColors.grisMed);
  }

  // --- FINANCIAL INSIGHTS ---
  static List<AIFinancialInsight> generateInsights(List<Transaction> transactions) {
    final insights = <AIFinancialInsight>[];
    final expenses = transactions.where((t) => !t.isIncome).toList();
    final income = transactions.where((t) => t.isIncome).toList();

    final totalIncome = income.fold(0.0, (s, t) => s + t.amount);
    final totalExpense = expenses.fold(0.0, (s, t) => s + t.amount);
    final savingsRate = totalIncome > 0 ? (totalIncome - totalExpense) / totalIncome : 0;

    // Savings insight
    if (savingsRate > 0.30) {
      insights.add(AIFinancialInsight(
        title: 'Tasa de ahorro ${(savingsRate * 100).toStringAsFixed(0)}%',
        description: 'Estas ahorrando mas del 30% de tus ingresos. Excelente disciplina financiera.',
        type: 'achievement',
        icon: Icons.emoji_events_rounded,
        color: SayoColors.green,
      ));
    } else if (savingsRate > 0.10) {
      insights.add(AIFinancialInsight(
        title: 'Ahorro del ${(savingsRate * 100).toStringAsFixed(0)}%',
        description: 'Buen ritmo de ahorro. Intenta llegar al 30% para mayor estabilidad.',
        type: 'tip',
        icon: Icons.savings_rounded,
        color: SayoColors.blue,
      ));
    } else {
      insights.add(AIFinancialInsight(
        title: 'Ahorro bajo: ${(savingsRate * 100).toStringAsFixed(0)}%',
        description: 'Tu gasto esta muy cerca de tus ingresos. Revisa gastos variables.',
        type: 'warning',
        icon: Icons.warning_rounded,
        color: SayoColors.orange,
      ));
    }

    // Subscription detection
    final subs = expenses.where((t) => t.title.toLowerCase().contains('netflix') || t.title.toLowerCase().contains('spotify')).toList();
    if (subs.isNotEmpty) {
      final subTotal = subs.fold(0.0, (s, t) => s + t.amount);
      insights.add(AIFinancialInsight(
        title: '${subs.length} suscripciones activas',
        description: 'Gastas \$${subTotal.toStringAsFixed(0)}/mes en suscripciones. Revisa cuales realmente usas.',
        type: 'saving',
        icon: Icons.subscriptions_rounded,
        color: SayoColors.purple,
        actionLabel: 'Revisar suscripciones',
      ));
    }

    // Spending pattern
    final transfersOut = expenses.where((t) => t.title.toLowerCase().contains('spei')).toList();
    if (transfersOut.length >= 2) {
      final avgTransfer = transfersOut.fold(0.0, (s, t) => s + t.amount) / transfersOut.length;
      insights.add(AIFinancialInsight(
        title: '${transfersOut.length} transferencias enviadas',
        description: 'Promedio de \$${avgTransfer.toStringAsFixed(0)} por transferencia. Representan el ${(transfersOut.fold(0.0, (s, t) => s + t.amount) / totalExpense * 100).toStringAsFixed(0)}% de tus gastos.',
        type: 'tip',
        icon: Icons.swap_horiz_rounded,
        color: SayoColors.blue,
      ));
    }

    // Income regularity
    final salaries = income.where((t) => t.title.toLowerCase().contains('nomina')).toList();
    if (salaries.length >= 2) {
      insights.add(AIFinancialInsight(
        title: 'Ingreso estable detectado',
        description: 'Tu nomina se deposita regularmente. Esto mejora tu perfil crediticio y te da acceso a mejores tasas.',
        type: 'achievement',
        icon: Icons.trending_up_rounded,
        color: SayoColors.green,
      ));
    }

    // Largest expense alert
    if (expenses.isNotEmpty) {
      final largest = expenses.reduce((a, b) => a.amount > b.amount ? a : b);
      if (largest.amount > totalExpense * 0.25) {
        insights.add(AIFinancialInsight(
          title: 'Gasto significativo detectado',
          description: '"${largest.title}" por \$${largest.amount.toStringAsFixed(0)} representa ${(largest.amount / totalExpense * 100).toStringAsFixed(0)}% de tus gastos del periodo.',
          type: 'tip',
          icon: Icons.visibility_rounded,
          color: SayoColors.orange,
        ));
      }
    }

    // Credit payment health
    final creditPayments = expenses.where((t) => t.title.toLowerCase().contains('credito')).toList();
    if (creditPayments.isNotEmpty) {
      final creditTotal = creditPayments.fold(0.0, (s, t) => s + t.amount);
      final dti = totalIncome > 0 ? creditTotal / totalIncome : 0;
      if (dti > 0.35) {
        insights.add(AIFinancialInsight(
          title: 'Carga crediticia alta',
          description: 'Tus pagos de credito representan el ${(dti * 100).toStringAsFixed(0)}% de tus ingresos. Lo recomendado es menos del 35%.',
          type: 'warning',
          icon: Icons.credit_card_off_rounded,
          color: SayoColors.red,
        ));
      } else {
        insights.add(AIFinancialInsight(
          title: 'Credito bajo control',
          description: 'Tus pagos de credito son el ${(dti * 100).toStringAsFixed(0)}% de tus ingresos. Dentro del rango saludable.',
          type: 'achievement',
          icon: Icons.verified_rounded,
          color: SayoColors.green,
        ));
      }
    }

    return insights;
  }

  // --- MONTHLY FORECAST ---
  static AIMonthlyForecast forecastNextMonth(List<Transaction> transactions) {
    // Simple moving average forecast
    final now = DateTime.now();
    final thisMonth = transactions.where((t) {
      final diff = now.difference(t.date).inDays;
      return diff <= 30;
    }).toList();
    final lastMonth = transactions.where((t) {
      final diff = now.difference(t.date).inDays;
      return diff > 30 && diff <= 60;
    }).toList();

    final thisIncome = thisMonth.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final lastIncome = lastMonth.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final thisExpense = thisMonth.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final lastExpense = lastMonth.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);

    final predictedIncome = (thisIncome + lastIncome) / 2 * 1.02;
    final predictedExpense = (thisExpense + lastExpense) / 2 * 1.01;

    return AIMonthlyForecast(
      predictedIncome: predictedIncome,
      predictedExpense: predictedExpense,
      predictedSavings: predictedIncome - predictedExpense,
      confidence: 0.78,
    );
  }

  // --- PRODUCT RECOMMENDATIONS ---
  static List<AIProductRecommendation> recommendProducts(AdminWalletUser user) {
    final score = calculateCreditScore(user);
    final recommendations = <AIProductRecommendation>[];

    // Adelanto Nomina
    if (score.score >= 500) {
      final rate = (0.12 + score.defaultProbability * 0.03).clamp(0.11, 0.15);
      final amount = (user.balance * 0.5).clamp(5000, 30000);
      recommendations.add(AIProductRecommendation(
        productType: 'adelanto',
        productName: 'Adelanto Nomina',
        matchScore: score.score >= 700 ? 95 : score.score >= 600 ? 80 : 65,
        reason: 'Aprobacion inmediata basada en tu historial de nomina',
        suggestedAmount: amount.toDouble(),
        suggestedRate: rate,
        suggestedPlazo: 2,
        estimatedPayment: amount / 2 * (1 + rate / 12),
        icon: Icons.flash_on_rounded,
        color: SayoColors.orange,
      ));
    }

    // Credito Nomina
    if (score.score >= 580) {
      final rate = (0.15 + score.defaultProbability * 0.05).clamp(0.13, 0.20);
      final amount = (score.suggestedLimit * 0.6).clamp(10000, 150000);
      recommendations.add(AIProductRecommendation(
        productType: 'nomina',
        productName: 'Credito sobre Nomina',
        matchScore: score.score >= 700 ? 90 : score.score >= 650 ? 78 : 60,
        reason: 'Tasa preferencial por ${score.tier.toLowerCase()} score crediticio',
        suggestedAmount: amount.toDouble(),
        suggestedRate: rate,
        suggestedPlazo: 12,
        estimatedPayment: amount / 12 * (1 + rate / 12),
        icon: Icons.account_balance_wallet_rounded,
        color: SayoColors.green,
      ));
    }

    // Credito Simple
    if (score.score >= 650) {
      final rate = (0.18 + score.defaultProbability * 0.06).clamp(0.16, 0.25);
      final amount = (score.suggestedLimit).clamp(20000, 500000);
      recommendations.add(AIProductRecommendation(
        productType: 'simple',
        productName: 'Credito Simple',
        matchScore: score.score >= 750 ? 85 : 68,
        reason: 'Mayor flexibilidad con limite personalizado de ${score.tier.toLowerCase()} riesgo',
        suggestedAmount: amount.toDouble(),
        suggestedRate: rate,
        suggestedPlazo: 24,
        estimatedPayment: amount / 24 * (1 + rate / 12),
        icon: Icons.payments_rounded,
        color: SayoColors.blue,
      ));
    }

    // Revolvente
    if (score.score >= 600 && user.creditUsedPercent < 0.70) {
      final rate = (0.22 + score.defaultProbability * 0.04).clamp(0.20, 0.28);
      final amount = (score.suggestedLimit * 0.4).clamp(10000, 200000);
      recommendations.add(AIProductRecommendation(
        productType: 'revolvente',
        productName: 'Credito Revolvente',
        matchScore: score.score >= 700 ? 75 : 55,
        reason: 'Linea reusable ideal para gastos recurrentes',
        suggestedAmount: amount.toDouble(),
        suggestedRate: rate,
        suggestedPlazo: 6,
        estimatedPayment: amount / 6 * (1 + rate / 12),
        icon: Icons.autorenew_rounded,
        color: SayoColors.purple,
      ));
    }

    recommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return recommendations;
  }

  // --- SMART ALERTS ---
  static List<AISmartAlert> generateSmartAlerts() {
    final alerts = <AISmartAlert>[];
    final predictions = predictDelinquencies();

    // Delinquency alerts from predictions
    for (final p in predictions.where((p) => p.probability >= 0.30)) {
      alerts.add(AISmartAlert(
        id: 'AI_DEL_${p.creditId}',
        title: 'Riesgo de mora: ${p.userName}',
        description: '${(p.probability * 100).toStringAsFixed(0)}% probabilidad de impago en 30 dias. ${p.riskFactors.join(", ")}.',
        severity: p.probability >= 0.70 ? 'critical' : p.probability >= 0.40 ? 'high' : 'medium',
        category: 'delinquency',
        color: p.riskColor,
        icon: Icons.trending_down_rounded,
        recommendedAction: p.recommendedAction,
        confidence: p.probability,
        generatedAt: DateTime.now(),
        userId: p.userId,
      ));
    }

    // Utilization alerts
    for (final user in mockAdminUsers) {
      if (user.creditUsedPercent >= 0.85 && user.status == 'activo') {
        alerts.add(AISmartAlert(
          id: 'AI_UTIL_${user.id}',
          title: 'Alta utilizacion: ${user.name}',
          description: 'Utilizacion de ${(user.creditUsedPercent * 100).toStringAsFixed(0)}% de linea. Riesgo de sobre-endeudamiento.',
          severity: user.creditUsedPercent >= 0.95 ? 'high' : 'medium',
          category: 'utilization',
          color: SayoColors.orange,
          icon: Icons.data_usage_rounded,
          recommendedAction: 'Revisar capacidad de pago y considerar ajuste de limite',
          confidence: 0.85,
          generatedAt: DateTime.now(),
          userId: user.id,
        ));
      }
    }

    // Liquidity alerts
    for (final user in mockAdminUsers) {
      final userCredits = mockCreditAssignments.where((c) => c.userId == user.id && c.status != 'liquidado');
      final totalPayments = userCredits.fold(0.0, (s, c) => s + c.monthlyPayment);
      if (totalPayments > 0 && user.balance < totalPayments * 1.5 && user.status == 'activo') {
        alerts.add(AISmartAlert(
          id: 'AI_LIQ_${user.id}',
          title: 'Liquidez baja: ${user.name}',
          description: 'Saldo \$${user.balance.toStringAsFixed(0)} vs pagos mensuales \$${totalPayments.toStringAsFixed(0)}. Cobertura de ${(user.balance / totalPayments).toStringAsFixed(1)}x.',
          severity: user.balance < totalPayments ? 'critical' : 'medium',
          category: 'liquidity',
          color: SayoColors.red,
          icon: Icons.account_balance_rounded,
          recommendedAction: 'Contactar proactivamente antes de fecha de pago',
          confidence: 0.90,
          generatedAt: DateTime.now(),
          userId: user.id,
        ));
      }
    }

    // Inactivity alert
    for (final user in mockAdminUsers) {
      final daysSinceActive = DateTime.now().difference(user.lastActivity).inDays;
      if (daysSinceActive > 30 && user.status == 'activo') {
        alerts.add(AISmartAlert(
          id: 'AI_INACT_${user.id}',
          title: 'Inactividad: ${user.name}',
          description: '$daysSinceActive dias sin actividad. Posible abandono o cambio de proveedor.',
          severity: 'low',
          category: 'utilization',
          color: SayoColors.grisMed,
          icon: Icons.access_time_rounded,
          recommendedAction: 'Enviar incentivo de reactivacion',
          confidence: 0.65,
          generatedAt: DateTime.now(),
          userId: user.id,
        ));
      }
    }

    // Portfolio concentration
    final totalUsed = AdminSummary.totalCreditUsed;
    for (final user in mockAdminUsers) {
      if (totalUsed > 0 && user.creditUsed / totalUsed > 0.25) {
        alerts.add(AISmartAlert(
          id: 'AI_CONC_${user.id}',
          title: 'Concentracion: ${user.name}',
          description: 'Representa ${(user.creditUsed / totalUsed * 100).toStringAsFixed(0)}% del portafolio total. Riesgo de concentracion.',
          severity: 'medium',
          category: 'fraud',
          color: SayoColors.purple,
          icon: Icons.pie_chart_rounded,
          recommendedAction: 'Diversificar portafolio con nuevos clientes',
          confidence: 0.82,
          generatedAt: DateTime.now(),
          userId: user.id,
        ));
      }
    }

    alerts.sort((a, b) {
      const order = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3};
      return (order[a.severity] ?? 4).compareTo(order[b.severity] ?? 4);
    });

    return alerts;
  }
}

// --- HELPERS ---

class _CategoryAccum {
  final String name;
  final String icon;
  final Color color;
  final double amount;
  const _CategoryAccum(this.name, this.icon, this.color, this.amount);
}

class _TxCategory {
  final String name;
  final String icon;
  final Color color;
  const _TxCategory(this.name, this.icon, this.color);
}
