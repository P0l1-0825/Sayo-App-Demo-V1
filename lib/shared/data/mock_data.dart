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

// Extended transactions covering ~3 months for Movimientos & Estados de Cuenta
final List<Transaction> mockTransactionsExtended = [
  // --- Current month ---
  Transaction(
    id: 'ext1',
    title: 'SPEI Recibido',
    subtitle: 'De: Carlos Mendoza',
    amount: 15000.00,
    isIncome: true,
    date: DateTime.now().subtract(const Duration(hours: 2)),
    icon: '↓',
    color: SayoColors.green,
  ),
  Transaction(
    id: 'ext2',
    title: 'Amazon',
    subtitle: 'Compra en linea',
    amount: 1299.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(hours: 5)),
    icon: '🛒',
    color: SayoColors.orange,
  ),
  Transaction(
    id: 'ext3',
    title: 'CFE',
    subtitle: 'Pago de luz',
    amount: 847.50,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 1)),
    icon: '⚡',
    color: SayoColors.blue,
  ),
  Transaction(
    id: 'ext4',
    title: 'SPEI Enviado',
    subtitle: 'A: Maria Lopez',
    amount: 5000.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
    icon: '↑',
    color: SayoColors.red,
  ),
  Transaction(
    id: 'ext5',
    title: 'Nomina',
    subtitle: 'Solvendom SAPI',
    amount: 32000.00,
    isIncome: true,
    date: DateTime.now().subtract(const Duration(days: 3)),
    icon: '💰',
    color: SayoColors.green,
  ),
  Transaction(
    id: 'ext6',
    title: 'Uber',
    subtitle: 'Viaje GDL Centro',
    amount: 189.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 4)),
    icon: '🚗',
    color: SayoColors.gris,
  ),
  Transaction(
    id: 'ext7',
    title: 'Oxxo',
    subtitle: 'Compra tienda',
    amount: 156.50,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 5)),
    icon: '🏪',
    color: SayoColors.orange,
  ),
  Transaction(
    id: 'ext8',
    title: 'Netflix',
    subtitle: 'Suscripcion mensual',
    amount: 299.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 7)),
    icon: '🎬',
    color: SayoColors.red,
  ),
  Transaction(
    id: 'ext9',
    title: 'SPEI Recibido',
    subtitle: 'De: Empresa ABC',
    amount: 8500.00,
    isIncome: true,
    date: DateTime.now().subtract(const Duration(days: 10)),
    icon: '↓',
    color: SayoColors.green,
  ),
  Transaction(
    id: 'ext10',
    title: 'Liverpool',
    subtitle: 'Compra departamental',
    amount: 3450.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 12)),
    icon: '🛍️',
    color: SayoColors.purple,
  ),
  // --- Previous month ---
  Transaction(
    id: 'ext11',
    title: 'Nomina',
    subtitle: 'Solvendom SAPI',
    amount: 32000.00,
    isIncome: true,
    date: DateTime.now().subtract(const Duration(days: 33)),
    icon: '💰',
    color: SayoColors.green,
  ),
  Transaction(
    id: 'ext12',
    title: 'Telmex',
    subtitle: 'Pago internet',
    amount: 599.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 35)),
    icon: '📡',
    color: SayoColors.blue,
  ),
  Transaction(
    id: 'ext13',
    title: 'SPEI Enviado',
    subtitle: 'A: Roberto Sanchez',
    amount: 12000.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 37)),
    icon: '↑',
    color: SayoColors.red,
  ),
  Transaction(
    id: 'ext14',
    title: 'Amazon',
    subtitle: 'Compra en linea',
    amount: 2150.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 38)),
    icon: '🛒',
    color: SayoColors.orange,
  ),
  Transaction(
    id: 'ext15',
    title: 'SPEI Recibido',
    subtitle: 'De: Laura Martinez',
    amount: 4000.00,
    isIncome: true,
    date: DateTime.now().subtract(const Duration(days: 40)),
    icon: '↓',
    color: SayoColors.green,
  ),
  Transaction(
    id: 'ext16',
    title: 'Uber Eats',
    subtitle: 'Pedido comida',
    amount: 385.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 42)),
    icon: '🍔',
    color: SayoColors.orange,
  ),
  Transaction(
    id: 'ext17',
    title: 'Pago Credito',
    subtitle: 'Cuota mensual SAYO',
    amount: 3500.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 45)),
    icon: '🏦',
    color: SayoColors.cafe,
  ),
  Transaction(
    id: 'ext18',
    title: 'Nomina',
    subtitle: 'Solvendom SAPI',
    amount: 32000.00,
    isIncome: true,
    date: DateTime.now().subtract(const Duration(days: 48)),
    icon: '💰',
    color: SayoColors.green,
  ),
  Transaction(
    id: 'ext19',
    title: 'Spotify',
    subtitle: 'Plan familiar',
    amount: 199.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 50)),
    icon: '🎵',
    color: SayoColors.green,
  ),
  // --- 2 months ago ---
  Transaction(
    id: 'ext20',
    title: 'Nomina',
    subtitle: 'Solvendom SAPI',
    amount: 32000.00,
    isIncome: true,
    date: DateTime.now().subtract(const Duration(days: 63)),
    icon: '💰',
    color: SayoColors.green,
  ),
  Transaction(
    id: 'ext21',
    title: 'CFE',
    subtitle: 'Pago de luz',
    amount: 920.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 65)),
    icon: '⚡',
    color: SayoColors.blue,
  ),
  Transaction(
    id: 'ext22',
    title: 'SPEI Recibido',
    subtitle: 'De: Ana Garcia',
    amount: 6000.00,
    isIncome: true,
    date: DateTime.now().subtract(const Duration(days: 68)),
    icon: '↓',
    color: SayoColors.green,
  ),
  Transaction(
    id: 'ext23',
    title: 'Soriana',
    subtitle: 'Despensa semanal',
    amount: 1875.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 70)),
    icon: '🛒',
    color: SayoColors.orange,
  ),
  Transaction(
    id: 'ext24',
    title: 'Pago Credito',
    subtitle: 'Cuota mensual SAYO',
    amount: 3500.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 75)),
    icon: '🏦',
    color: SayoColors.cafe,
  ),
  Transaction(
    id: 'ext25',
    title: 'SPEI Enviado',
    subtitle: 'A: Pedro Ramirez',
    amount: 7500.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 78)),
    icon: '↑',
    color: SayoColors.red,
  ),
  Transaction(
    id: 'ext26',
    title: 'Nomina',
    subtitle: 'Solvendom SAPI',
    amount: 32000.00,
    isIncome: true,
    date: DateTime.now().subtract(const Duration(days: 80)),
    icon: '💰',
    color: SayoColors.green,
  ),
  Transaction(
    id: 'ext27',
    title: 'Gas Natural',
    subtitle: 'Pago bimestral',
    amount: 450.00,
    isIncome: false,
    date: DateTime.now().subtract(const Duration(days: 82)),
    icon: '🔥',
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

// ── SAYO AI Mock Responses ──────────────────────────────────────────────────

class MockAI {
  static const Map<String, String> responses = {
    'gastos': 'Este mes llevas \$7,491 en gastos. Tu principal categoria es Compras en linea (\$3,449), seguido de Servicios (\$1,446) y Transporte (\$189). Comparado con el mes pasado, tus gastos bajaron un 12%. Tip: si reduces compras en linea un 20%, ahorras \$690 al mes.',
    'resumen': 'Resumen financiero de marzo 2026:\n\n💰 Ingresos: \$47,000\n💸 Egresos: \$7,491\n📊 Neto: +\$39,509\n\nTu saldo actual es \$47,520.83. Tienes un credito activo con saldo de \$42,000 y tu proxima cuota de \$3,500 vence el 6 de abril.',
    'credito': 'Tu linea de credito SAYO:\n\n• Limite: \$150,000\n• Usado: \$42,000 (28%)\n• Disponible: \$108,000\n• Tasa: 14% anual\n• Cuota mensual: \$3,500\n\nCon tu historial de pago puntual (2/12 pagadas), podrias calificar para un aumento de linea en 4 meses.',
    'pago': 'Tus proximos pagos programados:\n\n1. Credito SAYO - \$3,500 (6 abr)\n2. CFE - ~\$850 (15 abr)\n3. Netflix - \$299 (20 mar)\n4. Spotify - \$199 (25 mar)\n\nTotal estimado: \$4,848. Tienes saldo suficiente para cubrir todos.',
    'ahorro': 'Basado en tu patron de ingresos y gastos, podrias ahorrar hasta \$15,000 mensuales. Te recomiendo:\n\n1. Meta de emergencia: 3 meses de gastos = \$22,500\n2. Inversion: Con \$10,000/mes en CETES 28 dias ganas ~11.25% anual\n3. Automatizar: Programa un SPEI automatico el dia de nomina\n\nQuieres que simule un plan de ahorro personalizado?',
    'inversion': 'Opciones de inversion disponibles en SAYO:\n\n📈 CETES 28 dias: 11.25% anual (bajo riesgo)\n📊 CETES 91 dias: 11.40% anual (bajo riesgo)\n💎 Pagare SAYO: 12.5% anual (plazo 6 meses)\n\nCon tu saldo disponible de \$47,520, invirtiendo \$30,000 en CETES a 28 dias ganarias ~\$281 mensuales. Proximamente en SAYO.',
    'presupuesto': 'Tu presupuesto recomendado (regla 50/30/20):\n\nCon ingresos de \$37,000/mes:\n• 50% Necesidades: \$18,500 (renta, servicios, transporte)\n• 30% Deseos: \$11,100 (entretenimiento, compras)\n• 20% Ahorro: \$7,400\n\nActualmente gastas \$7,491 en total, muy por debajo. Excelente control financiero!',
    'transferencia': 'Para transferir dinero tienes estas opciones:\n\n1. SPEI inmediato (24/7) - Sin comision\n2. SPEI programado - Agenda fecha futura\n3. A contactos frecuentes - 1 tap\n\nTu ultimo SPEI fue de \$5,000 a Maria Lopez hace 1 dia. Quieres repetir esa transferencia?',
    'tarjeta': 'Tu tarjeta SAYO Mastercard:\n\n💳 Virtual: Activa (CVV dinamico cada 30s)\n💳 Fisica: Por solicitar\n\n• Limite diario: \$50,000\n• Limite online: \$30,000\n• Compras internacionales: Habilitado\n• Contactless NFC: Habilitado\n\nTu tarjeta virtual esta lista para pagar en cualquier comercio online.',
    'seguro': 'SAYO tiene proteccion incluida en tu cuenta:\n\n🛡️ Seguro de fraude: Cobertura 100%\n🔒 Bloqueo instantaneo desde la app\n📱 Notificaciones en tiempo real\n🔐 CVV dinamico (cambia cada 30s)\n\nPara mayor proteccion, activa 2FA en Perfil > Seguridad.',
    'puntos': 'Tus puntos SAYO:\n\n⭐ Saldo: 1,250 puntos (\$125 MXN)\n📊 Acumulados este mes: 320 pts\n💡 Regla: 1 punto por cada \$10 gastados\n\nPuedes canjear en: Netflix, Uber, Starbucks, Amazon, Liverpool y mas. Ve a Marketplace para ver el catalogo completo.',
    'ayuda': 'Puedo ayudarte con:\n\n💰 Consultar gastos y resumen financiero\n📊 Analizar tu presupuesto\n💳 Info sobre tu tarjeta y credito\n📈 Opciones de ahorro e inversion\n💸 Proximos pagos programados\n🔄 Transferencias y pagos\n⭐ Puntos SAYO y marketplace\n🛡️ Seguridad de tu cuenta\n\nEscribe tu pregunta o selecciona un tema.',
  };

  static const List<Map<String, dynamic>> suggestions = [
    {'icon': '📊', 'title': 'Analisis de gastos', 'subtitle': 'Revisa tus gastos del mes', 'keyword': 'gastos'},
    {'icon': '💰', 'title': 'Resumen financiero', 'subtitle': 'Balance general de tu cuenta', 'keyword': 'resumen'},
    {'icon': '📈', 'title': 'Opciones de ahorro', 'subtitle': 'Estrategias para ahorrar mas', 'keyword': 'ahorro'},
    {'icon': '💳', 'title': 'Mi credito SAYO', 'subtitle': 'Estado de tu linea de credito', 'keyword': 'credito'},
    {'icon': '🏦', 'title': 'Presupuesto', 'subtitle': 'Planifica tus finanzas', 'keyword': 'presupuesto'},
    {'icon': '⭐', 'title': 'Mis puntos', 'subtitle': 'Saldo y opciones de canje', 'keyword': 'puntos'},
  ];

  static String getResponse(String input) {
    final lower = input.toLowerCase();
    for (final key in responses.keys) {
      if (lower.contains(key)) return responses[key]!;
    }
    return 'Entiendo tu consulta. Estoy procesando la informacion de tu cuenta SAYO para darte una respuesta personalizada.\n\nMientras tanto, puedo ayudarte con: gastos, resumen financiero, credito, pagos, ahorro, inversiones, presupuesto, tarjeta o puntos SAYO.\n\nEscribe el tema que te interesa.';
  }
}

// ── Marketplace Mock Data ───────────────────────────────────────────────────

class MockMarketplace {
  static const int puntosBalance = 1250;
  static double get puntosValor => puntosBalance / 10.0;

  static const List<Map<String, dynamic>> categories = [
    {'id': 'restaurantes', 'name': 'Restaurantes', 'icon': Icons.restaurant_rounded, 'color': SayoColors.red},
    {'id': 'entretenimiento', 'name': 'Entretenimiento', 'icon': Icons.movie_rounded, 'color': SayoColors.purple},
    {'id': 'viajes', 'name': 'Viajes', 'icon': Icons.flight_rounded, 'color': SayoColors.blue},
    {'id': 'cashback', 'name': 'Cashback', 'icon': Icons.money_rounded, 'color': SayoColors.green},
    {'id': 'experiencias', 'name': 'Experiencias', 'icon': Icons.star_rounded, 'color': SayoColors.orange},
  ];

  static const List<Map<String, dynamic>> benefits = [
    {
      'id': 'b1', 'name': 'Netflix 1 mes', 'brand': 'Netflix',
      'points': 500, 'category': 'entretenimiento',
      'description': 'Disfruta 1 mes de Netflix Plan Basico. Codigo canjeable en netflix.com.',
      'terms': 'Valido por 30 dias despues del canje. No acumulable. Sujeto a disponibilidad.',
      'icon': Icons.movie_rounded, 'color': SayoColors.red,
    },
    {
      'id': 'b2', 'name': 'Uber \$100', 'brand': 'Uber',
      'points': 1000, 'category': 'viajes',
      'description': 'Credito de \$100 MXN para viajes en Uber. Se aplica automaticamente.',
      'terms': 'Valido por 60 dias. Un uso por cuenta. Solo viajes, no Uber Eats.',
      'icon': Icons.local_taxi_rounded, 'color': SayoColors.gris,
    },
    {
      'id': 'b3', 'name': 'Amazon \$200', 'brand': 'Amazon',
      'points': 2000, 'category': 'cashback',
      'description': 'Gift card de \$200 MXN para Amazon Mexico. Entrega por email.',
      'terms': 'Sin fecha de expiracion. Aplicable a cualquier producto. No reembolsable.',
      'icon': Icons.shopping_cart_rounded, 'color': SayoColors.orange,
    },
    {
      'id': 'b4', 'name': 'Starbucks bebida', 'brand': 'Starbucks',
      'points': 300, 'category': 'restaurantes',
      'description': 'Cualquier bebida preparada tamano Grande. Presenta el QR en tienda.',
      'terms': 'Valido en sucursales participantes. No incluye extras ni alimentos.',
      'icon': Icons.coffee_rounded, 'color': SayoColors.green,
    },
    {
      'id': 'b5', 'name': 'Cinepolis 2 boletos', 'brand': 'Cinepolis',
      'points': 400, 'category': 'entretenimiento',
      'description': '2 boletos para cualquier funcion en Cinepolis. Salas tradicionales.',
      'terms': 'Valido de lunes a jueves. No incluye VIP, IMAX o 4DX. Sujeto a disponibilidad.',
      'icon': Icons.theaters_rounded, 'color': SayoColors.blue,
    },
    {
      'id': 'b6', 'name': 'Liverpool \$500', 'brand': 'Liverpool',
      'points': 5000, 'category': 'cashback',
      'description': 'Certificado de \$500 MXN para Liverpool. Valido en tienda y online.',
      'terms': 'Valido por 90 dias. Compra minima de \$500. No aplica con otras promociones.',
      'icon': Icons.store_rounded, 'color': SayoColors.purple,
    },
    {
      'id': 'b7', 'name': 'Spotify 3 meses', 'brand': 'Spotify',
      'points': 800, 'category': 'entretenimiento',
      'description': '3 meses de Spotify Premium Individual. Codigo de activacion por email.',
      'terms': 'Solo para cuentas nuevas o sin suscripcion activa. No transferible.',
      'icon': Icons.music_note_rounded, 'color': SayoColors.green,
    },
    {
      'id': 'b8', 'name': 'Rappi \$150', 'brand': 'Rappi',
      'points': 1500, 'category': 'restaurantes',
      'description': 'Credito de \$150 MXN para pedidos en Rappi. Aplica a todo el catalogo.',
      'terms': 'Valido por 30 dias. Pedido minimo de \$100. Un uso por cuenta.',
      'icon': Icons.delivery_dining_rounded, 'color': SayoColors.orange,
    },
  ];

  static const List<Map<String, dynamic>> redemptionHistory = [
    {'benefit': 'Starbucks bebida', 'points': 300, 'date': '28 Feb 2026', 'status': 'Canjeado'},
    {'benefit': 'Netflix 1 mes', 'points': 500, 'date': '15 Feb 2026', 'status': 'Canjeado'},
    {'benefit': 'Uber \$100', 'points': 1000, 'date': '02 Ene 2026', 'status': 'Canjeado'},
  ];
}

// ── QR/CoDi Mock Data ───────────────────────────────────────────────────────

class MockQR {
  static const List<Map<String, dynamic>> qrHistory = [
    {'id': 'qr1', 'amount': 500.00, 'concept': 'Comida oficina', 'date': '05 Mar 2026', 'status': 'Cobrado'},
    {'id': 'qr2', 'amount': 1200.00, 'concept': 'Materiales proyecto', 'date': '01 Mar 2026', 'status': 'Pendiente'},
    {'id': 'qr3', 'amount': 350.00, 'concept': 'Cooperacion equipo', 'date': '25 Feb 2026', 'status': 'Cobrado'},
    {'id': 'qr4', 'amount': 2000.00, 'concept': 'Freelance diseno', 'date': '20 Feb 2026', 'status': 'Cobrado'},
    {'id': 'qr5', 'amount': 150.00, 'concept': 'Cafe reunión', 'date': '18 Feb 2026', 'status': 'Expirado'},
  ];

  static const List<Map<String, dynamic>> codiOperations = [
    {'id': 'codi1', 'type': 'Cobro', 'amount': 850.00, 'counterpart': 'Juan Perez', 'date': '04 Mar 2026', 'status': 'Completado'},
    {'id': 'codi2', 'type': 'Pago', 'amount': 1500.00, 'counterpart': 'Tienda ABC', 'date': '28 Feb 2026', 'status': 'Completado'},
    {'id': 'codi3', 'type': 'Cobro', 'amount': 300.00, 'counterpart': 'Ana Martinez', 'date': '22 Feb 2026', 'status': 'Completado'},
  ];

  static const bool codiActive = true;
  static const String codiRegistrationDate = '15 Ene 2026';
}
