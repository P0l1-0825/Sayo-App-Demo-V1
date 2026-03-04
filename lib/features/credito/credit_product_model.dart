import 'package:flutter/material.dart';
import '../../core/theme/sayo_colors.dart';

class CreditProduct {
  final String id;
  final String name;
  final String shortName;
  final String description;
  final IconData icon;
  final Color color;
  final double rate;
  final double maxAmount;
  final double minAmount;
  final int minPlazo;
  final int maxPlazo;
  final int plazoDivisions;
  final double activeUsed;
  final double activeLimit;

  const CreditProduct({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    required this.icon,
    required this.color,
    required this.rate,
    required this.maxAmount,
    required this.minAmount,
    required this.minPlazo,
    required this.maxPlazo,
    required this.plazoDivisions,
    required this.activeUsed,
    required this.activeLimit,
  });

  double get activeAvailable => activeLimit - activeUsed;
  bool get hasActiveCredit => activeUsed > 0;
  double get usedPercent => activeLimit > 0 ? activeUsed / activeLimit : 0;
  bool get needsApplication => !hasActiveCredit;
}

final List<CreditProduct> creditProducts = [
  const CreditProduct(
    id: 'adelanto',
    name: 'Adelanto de Nomina',
    shortName: 'Adelanto',
    description: 'Recibe tu nomina por adelantado, deposito en minutos',
    icon: Icons.flash_on_rounded,
    color: SayoColors.orange,
    rate: 0.12,
    maxAmount: 30000,
    minAmount: 1000,
    minPlazo: 1,
    maxPlazo: 3,
    plazoDivisions: 2,
    activeUsed: 15000,
    activeLimit: 30000,
  ),
  const CreditProduct(
    id: 'nomina',
    name: 'Credito sobre Nomina',
    shortName: 'Sobre Nomina',
    description: 'Credito respaldado por tu nomina, tasas preferenciales',
    icon: Icons.account_balance_wallet_rounded,
    color: SayoColors.green,
    rate: 0.15,
    maxAmount: 150000,
    minAmount: 5000,
    minPlazo: 6,
    maxPlazo: 36,
    plazoDivisions: 10,
    activeUsed: 42000,
    activeLimit: 150000,
  ),
  const CreditProduct(
    id: 'simple',
    name: 'Credito Simple',
    shortName: 'Simple',
    description: 'Credito flexible para lo que necesites',
    icon: Icons.payments_rounded,
    color: SayoColors.blue,
    rate: 0.18,
    maxAmount: 500000,
    minAmount: 10000,
    minPlazo: 3,
    maxPlazo: 48,
    plazoDivisions: 9,
    activeUsed: 0,
    activeLimit: 500000,
  ),
  const CreditProduct(
    id: 'revolvente',
    name: 'Credito Revolvente',
    shortName: 'Revolvente',
    description: 'Linea de credito reutilizable, paga y vuelve a disponer',
    icon: Icons.autorenew_rounded,
    color: SayoColors.purple,
    rate: 0.22,
    maxAmount: 200000,
    minAmount: 5000,
    minPlazo: 1,
    maxPlazo: 12,
    plazoDivisions: 11,
    activeUsed: 28000,
    activeLimit: 200000,
  ),
];
