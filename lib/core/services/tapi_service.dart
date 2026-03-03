import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/tapi_models.dart';
import 'api_client.dart';

class TapiService {
  late final ApiClient _client;

  TapiService() {
    _client = ApiClient(
      baseUrl: ApiConfig.tapiBaseUrl,
      apiKey: ApiConfig.tapiApiKey,
    );
  }

  bool get _useMock => !ApiConfig.isTapiConfigured;

  // Categorias de servicios
  List<ServiceCategory> getCategories() {
    return _mockCategories;
  }

  // Empresas por categoria
  Future<List<ServiceCompany>> getCompanies(String categoryId) async {
    if (_useMock) return _mockCompanies[categoryId] ?? [];

    final response = await _client.get('/services', queryParams: {'category': categoryId});
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => ServiceCompany.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Consultar deuda
  Future<DebtQuery> queryDebt(String serviceId, String reference) async {
    if (_useMock) return _mockDebt(serviceId, reference);

    final response = await _client.post('/services/query', body: {
      'service_id': serviceId,
      'reference': reference,
    });
    return DebtQuery.fromJson(response['data'] as Map<String, dynamic>);
  }

  // Crear orden de pago
  Future<PaymentOrder> createPayment(String serviceId, String reference, double amount) async {
    if (_useMock) return _mockPayment(serviceId, reference, amount);

    final response = await _client.post('/services/pay', body: {
      'service_id': serviceId,
      'reference': reference,
      'amount': amount,
    });
    return PaymentOrder.fromJson(response['data'] as Map<String, dynamic>);
  }

  // Verificar estado de pago
  Future<PaymentOrder> getPaymentStatus(String orderId) async {
    if (_useMock) {
      return PaymentOrder(
        orderId: orderId,
        amount: 0,
        status: 'completed',
        timestamp: DateTime.now(),
        company: '',
        reference: '',
      );
    }

    final response = await _client.get('/services/status/$orderId');
    return PaymentOrder.fromJson(response['data'] as Map<String, dynamic>);
  }

  // ── Mock Data ──

  static final _mockCategories = [
    const ServiceCategory(
      id: 'electricidad',
      name: 'Electricidad',
      icon: Icons.bolt_rounded,
      color: Color(0xFFF59E0B),
    ),
    const ServiceCategory(
      id: 'agua',
      name: 'Agua',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF3B82F6),
    ),
    const ServiceCategory(
      id: 'gas',
      name: 'Gas',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFEF4444),
    ),
    const ServiceCategory(
      id: 'telefonia',
      name: 'Telefonia',
      icon: Icons.phone_android_rounded,
      color: Color(0xFF8B5CF6),
    ),
    const ServiceCategory(
      id: 'internet',
      name: 'Internet / TV',
      icon: Icons.wifi_rounded,
      color: Color(0xFF06B6D4),
    ),
    const ServiceCategory(
      id: 'recargas',
      name: 'Recargas',
      icon: Icons.smartphone_rounded,
      color: Color(0xFF10B981),
    ),
    const ServiceCategory(
      id: 'sat',
      name: 'SAT',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF6366F1),
    ),
    const ServiceCategory(
      id: 'otros',
      name: 'Otros',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF64748B),
    ),
  ];

  static final _mockCompanies = <String, List<ServiceCompany>>{
    'electricidad': [
      const ServiceCompany(id: 'cfe', name: 'CFE', categoryId: 'electricidad'),
    ],
    'agua': [
      const ServiceCompany(id: 'sacmex', name: 'SACMEX', categoryId: 'agua'),
      const ServiceCompany(id: 'siapa', name: 'SIAPA', categoryId: 'agua'),
      const ServiceCompany(id: 'cespt', name: 'CESPT', categoryId: 'agua'),
    ],
    'gas': [
      const ServiceCompany(id: 'naturgy', name: 'Naturgy', categoryId: 'gas'),
      const ServiceCompany(id: 'gas_natural', name: 'Gas Natural', categoryId: 'gas'),
    ],
    'telefonia': [
      const ServiceCompany(id: 'telcel', name: 'Telcel', categoryId: 'telefonia'),
      const ServiceCompany(id: 'telmex', name: 'Telmex', categoryId: 'telefonia'),
      const ServiceCompany(id: 'att', name: 'AT&T', categoryId: 'telefonia'),
      const ServiceCompany(id: 'movistar', name: 'Movistar', categoryId: 'telefonia'),
    ],
    'internet': [
      const ServiceCompany(id: 'totalplay', name: 'Totalplay', categoryId: 'internet'),
      const ServiceCompany(id: 'izzi', name: 'Izzi', categoryId: 'internet'),
      const ServiceCompany(id: 'sky', name: 'SKY', categoryId: 'internet'),
      const ServiceCompany(id: 'megacable', name: 'Megacable', categoryId: 'internet'),
    ],
    'recargas': [
      const ServiceCompany(id: 'rec_telcel', name: 'Telcel', categoryId: 'recargas'),
      const ServiceCompany(id: 'rec_att', name: 'AT&T', categoryId: 'recargas'),
      const ServiceCompany(id: 'rec_movistar', name: 'Movistar', categoryId: 'recargas'),
      const ServiceCompany(id: 'rec_unefon', name: 'Unefon', categoryId: 'recargas'),
    ],
    'sat': [
      const ServiceCompany(id: 'sat_impuestos', name: 'Pago de impuestos', categoryId: 'sat'),
      const ServiceCompany(id: 'sat_derechos', name: 'Derechos', categoryId: 'sat'),
    ],
    'otros': [
      const ServiceCompany(id: 'predial', name: 'Predial', categoryId: 'otros'),
      const ServiceCompany(id: 'tenencia', name: 'Tenencia', categoryId: 'otros'),
    ],
  };

  DebtQuery _mockDebt(String serviceId, String reference) {
    final names = {
      'cfe': 'CFE',
      'sacmex': 'SACMEX',
      'telmex': 'Telmex',
      'telcel': 'Telcel',
      'naturgy': 'Naturgy',
      'totalplay': 'Totalplay',
    };
    return DebtQuery(
      reference: reference,
      amount: 847.50,
      company: names[serviceId] ?? serviceId.toUpperCase(),
      concept: 'Periodo Ene-Feb 2026',
      dueDate: '15/03/2026',
      status: 'pending',
    );
  }

  PaymentOrder _mockPayment(String serviceId, String reference, double amount) {
    return PaymentOrder(
      orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      status: 'completed',
      timestamp: DateTime.now(),
      company: serviceId.toUpperCase(),
      reference: reference,
    );
  }
}
