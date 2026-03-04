import 'package:flutter/material.dart';
import '../../core/theme/sayo_colors.dart';

class MockUser {
  static const String name = 'Benito';
  static const String fullName = 'José Ignacio Benito';
  static const String phone = '+52 33 1234 5678';
  static const String email = 'benito@solvendom.com';
  static const String clabe = '646180204800012345';
  static const double balance = 47520.83;
  static const double creditLimit = 150000.00;
  static const double creditUsed = 42000.00;
  static const double creditAvailable = 108000.00;
  static const String kycLevel = 'Nivel 3';
}

class Transaction {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final bool isIncome;
  final DateTime date;
  final String icon;
  final Color color;

  const Transaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.date,
    required this.icon,
    required this.color,
  });
}

final List<Transaction> mockTransactions = [
  Transaction(
    id: '1',
    title: 'SPEI Recibido',
    subtitle: 'De: Carlos Mendoza',
    amount: 15000.00,
    isIncome: true,
    date: DateTime.now().subtract(const Duration(hours: 2)),
    icon: '↓',
    color: SayoColors.green,
  ),
  Transaction(
    id: '2',
    title: 'Amazon',
    subtitle: 'Compra en linea',
    amount: 1299.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(hours: 5)),
    icon: '🛒',
    color: SayoColors.orange,
  ),
  Transaction(
    id: '3',
    title: 'CFE',
    subtitle: 'Pago de luz',
    amount: 847.50,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 1)),
    icon: '⚡',
    color: SayoColors.blue,
  ),
  Transaction(
    id: '4',
    title: 'SPEI Enviado',
    subtitle: 'A: Maria Lopez',
    amount: 5000.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
    icon: '↑',
    color: SayoColors.red,
  ),
  Transaction(
    id: '5',
    title: 'Nomina',
    subtitle: 'Solvendom SAPI',
    amount: 32000.00,
    isIncome: true,
    date: DateTime.now().subtract(const Duration(days: 3)),
    icon: '💰',
    color: SayoColors.green,
  ),
  Transaction(
    id: '6',
    title: 'Uber',
    subtitle: 'Viaje GDL Centro',
    amount: 189.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 4)),
    icon: '🚗',
    color: SayoColors.gris,
  ),
  Transaction(
    id: '7',
    title: 'Oxxo',
    subtitle: 'Compra tienda',
    amount: 156.50,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 5)),
    icon: '🏪',
    color: SayoColors.orange,
  ),
];

class CreditPayment {
  final String id;
  final int number;
  final DateTime date;
  final double capital;
  final double interest;
  final double total;
  final double remainingBalance;
  final bool isPaid;

  const CreditPayment({
    required this.id,
    required this.number,
    required this.date,
    required this.capital,
    required this.interest,
    required this.total,
    required this.remainingBalance,
    required this.isPaid,
  });
}

final List<CreditPayment> mockPayments = List.generate(12, (i) {
  final date = DateTime.now().add(Duration(days: 30 * (i + 1)));
  final remaining = 42000.0 - (3500.0 * i);
  return CreditPayment(
    id: 'p${i + 1}',
    number: i + 1,
    date: date,
    capital: 3255.0,
    interest: 245.0,
    total: 3500.0,
    remainingBalance: remaining > 0 ? remaining : 0,
    isPaid: i < 2,
  );
});

class MockNomina {
  static const double salarioQuincenal = 18500.00;
  static const double porcentajeDisponible = 0.70;
  static double get montoMaximo => salarioQuincenal * porcentajeDisponible;
  static const String empresa = 'Solvendom Technologies';
  static const String proximoDeposito = '7 de marzo, 2026';
  static const String fechaDescuento = '15 de marzo, 2026';
}

class MockEmployment {
  static const String empresa = 'Solvendom Technologies';
  static const String puesto = 'Ingeniero de Software Sr.';
  static const double salarioMensual = 37000.00;
  static const int antiguedadMeses = 28;
  static const String tipoContrato = 'Indefinido';
  static const String rfc = 'BEGO920815XX1';
  static const String nss = '1234567890';
}

class MockCreditApplication {
  static const List<String> purposes = [
    'Capital de trabajo',
    'Compra de equipo',
    'Remodelacion',
    'Consolidacion de deudas',
    'Gastos personales',
    'Otro',
  ];

  static const List<Map<String, dynamic>> documents = [
    {'name': 'Identificacion oficial (INE)', 'status': 'verified', 'icon': '🪪'},
    {'name': 'Comprobante de domicilio', 'status': 'verified', 'icon': '🏠'},
    {'name': 'Comprobante de ingresos', 'status': 'verified', 'icon': '💰'},
    {'name': 'Estado de cuenta bancario', 'status': 'pending', 'icon': '🏦'},
  ];
}

class QuickAction {
  final String label;
  final IconData icon;
  final Color color;

  const QuickAction({
    required this.label,
    required this.icon,
    required this.color,
  });
}

const List<QuickAction> quickActions = [
  QuickAction(label: 'Transferir', icon: Icons.send_rounded, color: SayoColors.blue),
  QuickAction(label: 'Pagar', icon: Icons.receipt_long_rounded, color: SayoColors.green),
  QuickAction(label: 'Cobrar QR', icon: Icons.qr_code_rounded, color: SayoColors.purple),
  QuickAction(label: 'Nomina', icon: Icons.payments_rounded, color: SayoColors.orange),
];
