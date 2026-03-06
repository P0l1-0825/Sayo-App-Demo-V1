import 'package:flutter/material.dart';
import '../../core/theme/sayo_colors.dart';

// --- ADMIN USER MODEL ---

class AdminWalletUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String clabe;
  final String kycLevel;
  final double balance;
  final double creditLimit;
  final double creditUsed;
  final String status; // activo, suspendido, pendiente
  final DateTime createdAt;
  final DateTime lastActivity;

  const AdminWalletUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.clabe,
    required this.kycLevel,
    required this.balance,
    required this.creditLimit,
    required this.creditUsed,
    required this.status,
    required this.createdAt,
    required this.lastActivity,
  });

  double get creditAvailable => creditLimit - creditUsed;
  double get creditUsedPercent => creditLimit > 0 ? creditUsed / creditLimit : 0;

  Color get statusColor {
    switch (status) {
      case 'activo':
        return SayoColors.green;
      case 'suspendido':
        return SayoColors.red;
      case 'pendiente':
        return SayoColors.orange;
      default:
        return SayoColors.grisMed;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'activo':
        return 'Activo';
      case 'suspendido':
        return 'Suspendido';
      case 'pendiente':
        return 'Pendiente KYC';
      default:
        return status;
    }
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts[0][0];
  }
}

// --- CREDIT ASSIGNMENT MODEL ---

class CreditAssignment {
  final String id;
  final String userId;
  final String userName;
  final String productType; // adelanto, nomina, simple, revolvente
  final double assignedLimit;
  final double usedAmount;
  final double monthlyPayment;
  final int plazoMonths;
  final int paidMonths;
  final double interestRate;
  final String status; // vigente, vencido, liquidado, en_mora
  final DateTime assignedDate;
  final DateTime nextPaymentDate;

  const CreditAssignment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.productType,
    required this.assignedLimit,
    required this.usedAmount,
    required this.monthlyPayment,
    required this.plazoMonths,
    required this.paidMonths,
    required this.interestRate,
    required this.status,
    required this.assignedDate,
    required this.nextPaymentDate,
  });

  double get availableAmount => assignedLimit - usedAmount;
  double get usedPercent => assignedLimit > 0 ? usedAmount / assignedLimit : 0;
  int get remainingMonths => plazoMonths - paidMonths;
  double get totalDebt => monthlyPayment * remainingMonths;

  Color get statusColor {
    switch (status) {
      case 'vigente':
        return SayoColors.green;
      case 'vencido':
        return SayoColors.red;
      case 'liquidado':
        return SayoColors.blue;
      case 'en_mora':
        return SayoColors.orange;
      default:
        return SayoColors.grisMed;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'vigente':
        return 'Vigente';
      case 'vencido':
        return 'Vencido';
      case 'liquidado':
        return 'Liquidado';
      case 'en_mora':
        return 'En mora';
      default:
        return status;
    }
  }

  String get productLabel {
    switch (productType) {
      case 'adelanto':
        return 'Adelanto Nomina';
      case 'nomina':
        return 'Credito Nomina';
      case 'simple':
        return 'Credito Simple';
      case 'revolvente':
        return 'Revolvente';
      default:
        return productType;
    }
  }

  IconData get productIcon {
    switch (productType) {
      case 'adelanto':
        return Icons.flash_on_rounded;
      case 'nomina':
        return Icons.account_balance_wallet_rounded;
      case 'simple':
        return Icons.payments_rounded;
      case 'revolvente':
        return Icons.autorenew_rounded;
      default:
        return Icons.credit_card_rounded;
    }
  }

  Color get productColor {
    switch (productType) {
      case 'adelanto':
        return SayoColors.orange;
      case 'nomina':
        return SayoColors.green;
      case 'simple':
        return SayoColors.blue;
      case 'revolvente':
        return SayoColors.purple;
      default:
        return SayoColors.grisMed;
    }
  }
}

// --- ADMIN ALERT MODEL ---

class AdminAlert {
  final String id;
  final String title;
  final String description;
  final String type; // warning, danger, info
  final DateTime date;

  const AdminAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
  });

  Color get color {
    switch (type) {
      case 'danger':
        return SayoColors.red;
      case 'warning':
        return SayoColors.orange;
      case 'info':
        return SayoColors.blue;
      default:
        return SayoColors.grisMed;
    }
  }

  IconData get icon {
    switch (type) {
      case 'danger':
        return Icons.error_rounded;
      case 'warning':
        return Icons.warning_rounded;
      case 'info':
        return Icons.info_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}

// --- MOCK DATA ---

final mockAdminUsers = <AdminWalletUser>[
  AdminWalletUser(
    id: 'USR001',
    name: 'José Ignacio Benito',
    email: 'benito@solvendom.com',
    phone: '+52 33 1234 5678',
    clabe: '646180204800012345',
    kycLevel: 'Nivel 3',
    balance: 47520.83,
    creditLimit: 150000,
    creditUsed: 42000,
    status: 'activo',
    createdAt: DateTime(2025, 6, 15),
    lastActivity: DateTime(2026, 3, 3),
  ),
  AdminWalletUser(
    id: 'USR002',
    name: 'María García López',
    email: 'maria.garcia@email.com',
    phone: '+52 55 9876 5432',
    clabe: '646180204800023456',
    kycLevel: 'Nivel 3',
    balance: 125340.50,
    creditLimit: 300000,
    creditUsed: 180000,
    status: 'activo',
    createdAt: DateTime(2025, 4, 20),
    lastActivity: DateTime(2026, 3, 4),
  ),
  AdminWalletUser(
    id: 'USR003',
    name: 'Carlos Mendoza Ruiz',
    email: 'carlos.mendoza@empresa.mx',
    phone: '+52 81 5555 1234',
    clabe: '646180204800034567',
    kycLevel: 'Nivel 2',
    balance: 8750.00,
    creditLimit: 50000,
    creditUsed: 48500,
    status: 'activo',
    createdAt: DateTime(2025, 9, 10),
    lastActivity: DateTime(2026, 3, 2),
  ),
  AdminWalletUser(
    id: 'USR004',
    name: 'Ana Sofía Torres',
    email: 'ana.torres@mail.com',
    phone: '+52 33 4444 8888',
    clabe: '646180204800045678',
    kycLevel: 'Nivel 3',
    balance: 312800.00,
    creditLimit: 500000,
    creditUsed: 0,
    status: 'activo',
    createdAt: DateTime(2025, 3, 1),
    lastActivity: DateTime(2026, 3, 4),
  ),
  AdminWalletUser(
    id: 'USR005',
    name: 'Roberto Hernández',
    email: 'roberto.h@outlook.com',
    phone: '+52 55 1111 2222',
    clabe: '646180204800056789',
    kycLevel: 'Nivel 1',
    balance: 0,
    creditLimit: 0,
    creditUsed: 0,
    status: 'pendiente',
    createdAt: DateTime(2026, 3, 1),
    lastActivity: DateTime(2026, 3, 1),
  ),
  AdminWalletUser(
    id: 'USR006',
    name: 'Laura Díaz Moreno',
    email: 'laura.diaz@gmail.com',
    phone: '+52 442 333 4455',
    clabe: '646180204800067890',
    kycLevel: 'Nivel 3',
    balance: 1200.00,
    creditLimit: 100000,
    creditUsed: 95000,
    status: 'activo',
    createdAt: DateTime(2025, 7, 22),
    lastActivity: DateTime(2026, 2, 28),
  ),
  AdminWalletUser(
    id: 'USR007',
    name: 'Fernando Reyes',
    email: 'freyes@empresa.com',
    phone: '+52 33 7777 9999',
    clabe: '646180204800078901',
    kycLevel: 'Nivel 2',
    balance: 56430.25,
    creditLimit: 200000,
    creditUsed: 120000,
    status: 'suspendido',
    createdAt: DateTime(2025, 5, 8),
    lastActivity: DateTime(2026, 1, 15),
  ),
  AdminWalletUser(
    id: 'USR008',
    name: 'Patricia Vega Sánchez',
    email: 'pvega@correo.mx',
    phone: '+52 81 2222 3333',
    clabe: '646180204800089012',
    kycLevel: 'Nivel 3',
    balance: 89100.00,
    creditLimit: 250000,
    creditUsed: 75000,
    status: 'activo',
    createdAt: DateTime(2025, 8, 14),
    lastActivity: DateTime(2026, 3, 3),
  ),
];

final mockCreditAssignments = <CreditAssignment>[
  CreditAssignment(
    id: 'CRD001',
    userId: 'USR001',
    userName: 'José Ignacio Benito',
    productType: 'nomina',
    assignedLimit: 150000,
    usedAmount: 42000,
    monthlyPayment: 4850,
    plazoMonths: 12,
    paidMonths: 2,
    interestRate: 0.15,
    status: 'vigente',
    assignedDate: DateTime(2025, 12, 1),
    nextPaymentDate: DateTime(2026, 3, 15),
  ),
  CreditAssignment(
    id: 'CRD002',
    userId: 'USR001',
    userName: 'José Ignacio Benito',
    productType: 'adelanto',
    assignedLimit: 30000,
    usedAmount: 15000,
    monthlyPayment: 5200,
    plazoMonths: 3,
    paidMonths: 1,
    interestRate: 0.12,
    status: 'vigente',
    assignedDate: DateTime(2026, 2, 1),
    nextPaymentDate: DateTime(2026, 3, 7),
  ),
  CreditAssignment(
    id: 'CRD003',
    userId: 'USR002',
    userName: 'María García López',
    productType: 'simple',
    assignedLimit: 300000,
    usedAmount: 180000,
    monthlyPayment: 12500,
    plazoMonths: 24,
    paidMonths: 8,
    interestRate: 0.18,
    status: 'vigente',
    assignedDate: DateTime(2025, 7, 1),
    nextPaymentDate: DateTime(2026, 3, 10),
  ),
  CreditAssignment(
    id: 'CRD004',
    userId: 'USR003',
    userName: 'Carlos Mendoza Ruiz',
    productType: 'nomina',
    assignedLimit: 50000,
    usedAmount: 48500,
    monthlyPayment: 6200,
    plazoMonths: 12,
    paidMonths: 9,
    interestRate: 0.15,
    status: 'en_mora',
    assignedDate: DateTime(2025, 5, 15),
    nextPaymentDate: DateTime(2026, 2, 15),
  ),
  CreditAssignment(
    id: 'CRD005',
    userId: 'USR006',
    userName: 'Laura Díaz Moreno',
    productType: 'revolvente',
    assignedLimit: 100000,
    usedAmount: 95000,
    monthlyPayment: 9800,
    plazoMonths: 12,
    paidMonths: 4,
    interestRate: 0.22,
    status: 'vigente',
    assignedDate: DateTime(2025, 11, 1),
    nextPaymentDate: DateTime(2026, 3, 12),
  ),
  CreditAssignment(
    id: 'CRD006',
    userId: 'USR007',
    userName: 'Fernando Reyes',
    productType: 'simple',
    assignedLimit: 200000,
    usedAmount: 120000,
    monthlyPayment: 8900,
    plazoMonths: 36,
    paidMonths: 10,
    interestRate: 0.18,
    status: 'vencido',
    assignedDate: DateTime(2025, 4, 1),
    nextPaymentDate: DateTime(2026, 2, 1),
  ),
  CreditAssignment(
    id: 'CRD007',
    userId: 'USR008',
    userName: 'Patricia Vega Sánchez',
    productType: 'nomina',
    assignedLimit: 250000,
    usedAmount: 75000,
    monthlyPayment: 5600,
    plazoMonths: 18,
    paidMonths: 3,
    interestRate: 0.15,
    status: 'vigente',
    assignedDate: DateTime(2025, 12, 15),
    nextPaymentDate: DateTime(2026, 3, 15),
  ),
  CreditAssignment(
    id: 'CRD008',
    userId: 'USR004',
    userName: 'Ana Sofía Torres',
    productType: 'adelanto',
    assignedLimit: 30000,
    usedAmount: 0,
    monthlyPayment: 0,
    plazoMonths: 0,
    paidMonths: 0,
    interestRate: 0.12,
    status: 'liquidado',
    assignedDate: DateTime(2025, 10, 1),
    nextPaymentDate: DateTime(2026, 1, 1),
  ),
];

final mockAdminAlerts = <AdminAlert>[
  AdminAlert(
    id: 'ALR001',
    title: 'Credito en mora',
    description: 'Carlos Mendoza tiene 1 pago vencido en Credito Nomina. Saldo pendiente: \$48,500',
    type: 'danger',
    date: DateTime(2026, 3, 3),
  ),
  AdminAlert(
    id: 'ALR002',
    title: 'Credito vencido',
    description: 'Fernando Reyes no ha pagado desde enero. Cuenta suspendida automaticamente.',
    type: 'danger',
    date: DateTime(2026, 2, 15),
  ),
  AdminAlert(
    id: 'ALR003',
    title: 'Alto uso de linea',
    description: 'Laura Diaz ha utilizado 95% de su linea revolvente (\$95,000 de \$100,000)',
    type: 'warning',
    date: DateTime(2026, 3, 2),
  ),
  AdminAlert(
    id: 'ALR004',
    title: 'KYC pendiente',
    description: 'Roberto Hernandez registro su cuenta pero no ha completado verificacion KYC',
    type: 'info',
    date: DateTime(2026, 3, 1),
  ),
  AdminAlert(
    id: 'ALR005',
    title: 'Saldo bajo',
    description: 'Carlos Mendoza tiene saldo de \$8,750 con pagos proximos por \$6,200',
    type: 'warning',
    date: DateTime(2026, 3, 2),
  ),
];

// --- ADMIN SUMMARY COMPUTED VALUES ---

class AdminSummary {
  static int get totalUsers => mockAdminUsers.length;
  static int get activeUsers => mockAdminUsers.where((u) => u.status == 'activo').length;
  static int get pendingUsers => mockAdminUsers.where((u) => u.status == 'pendiente').length;
  static int get suspendedUsers => mockAdminUsers.where((u) => u.status == 'suspendido').length;

  static double get totalBalance => mockAdminUsers.fold(0.0, (sum, u) => sum + u.balance);
  static double get totalCreditAssigned => mockCreditAssignments.fold(0.0, (sum, c) => sum + c.assignedLimit);
  static double get totalCreditUsed => mockCreditAssignments.where((c) => c.status != 'liquidado').fold(0.0, (sum, c) => sum + c.usedAmount);
  static double get totalCreditAvailable => totalCreditAssigned - totalCreditUsed;

  static int get activeCredits => mockCreditAssignments.where((c) => c.status == 'vigente').length;
  static int get overdueCredits => mockCreditAssignments.where((c) => c.status == 'en_mora' || c.status == 'vencido').length;
  static int get settledCredits => mockCreditAssignments.where((c) => c.status == 'liquidado').length;

  static double get monthlyRevenue => mockCreditAssignments
      .where((c) => c.status == 'vigente')
      .fold(0.0, (sum, c) => sum + c.monthlyPayment);

  static double get atRiskAmount => mockCreditAssignments
      .where((c) => c.status == 'en_mora' || c.status == 'vencido')
      .fold(0.0, (sum, c) => sum + c.usedAmount);
}
