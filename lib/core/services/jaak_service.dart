import 'dart:convert';
import '../config/api_config.dart';
import '../models/jaak_models.dart';
import 'api_client.dart';

class JaakService {
  late final ApiClient _client;

  JaakService() {
    _client = ApiClient(
      baseUrl: ApiConfig.jaakBaseUrl,
      apiKey: ApiConfig.jaakApiKey,
      timeout: const Duration(seconds: 60),
    );
  }

  bool get _useMock => !ApiConfig.isJaakConfigured;

  // 1. Crear sesion KYC
  Future<KycSession> createSession({
    required String name,
    String country = 'MX',
    String? email,
  }) async {
    if (_useMock) return _mockSession();

    final response = await _client.post('/api/v1/kyc/flow', body: {
      'name': name,
      'country': country,
      if (email != null) 'email': email,
    });
    return KycSession.fromFlowResponse(response);
  }

  // 2. Intercambiar shortKey por token
  Future<KycSession> exchangeToken(KycSession session) async {
    if (_useMock) return session.withToken('mock_token_123', 'mock_session_id');

    final response = await _client.post('/api/v1/kyc/session', body: {
      'short_key': session.shortKey,
    });
    return session.withToken(
      response['access_token'] as String,
      response['session_id'] as String,
    );
  }

  // 3. Registrar ubicacion
  Future<void> registerLocation(String token, double lat, double lng) async {
    if (_useMock) return;

    await _client.post('/api/v1/kyc/session/location', token: token, body: {
      'latitude': lat,
      'longitude': lng,
    });
  }

  // 4. Verificar documento (frente y reverso)
  Future<DocumentVerification> verifyDocument(
    String token, {
    required String frontBase64,
    String? backBase64,
  }) async {
    if (_useMock) return _mockDocVerification();

    final body = <String, dynamic>{
      'front': frontBase64,
    };
    if (backBase64 != null) body['back'] = backBase64;

    final response = await _client.post('/api/v3/document/verify', token: token, body: body);
    return DocumentVerification.fromJson(response);
  }

  // 5. Extraer datos del documento (OCR)
  Future<ExtractedData> extractData(
    String token, {
    required String frontBase64,
    String? backBase64,
  }) async {
    if (_useMock) return _mockExtractedData();

    final body = <String, dynamic>{
      'front': frontBase64,
    };
    if (backBase64 != null) body['back'] = backBase64;

    final response = await _client.post('/api/v4/document/extract', token: token, body: body);
    return ExtractedData.fromJson(response);
  }

  // 6. Investigar listas negras (RENAPO, OFAC, Interpol)
  Future<List<BlacklistResult>> investigateBlacklist(
    String token, {
    required String curp,
    required String fullName,
  }) async {
    if (_useMock) return _mockBlacklistResults();

    final response = await _client.post('/api/v2/blacklist/investigate', token: token, body: {
      'curp': curp,
      'full_name': fullName,
    });

    final results = response['results'] as List<dynamic>? ?? [];
    return results.map((e) => BlacklistResult.fromJson(e as Map<String, dynamic>)).toList();
  }

  // 7. Verificar liveness (prueba de vida)
  Future<LivenessResult> verifyLiveness(String token, {required String imageBase64}) async {
    if (_useMock) return _mockLiveness();

    final response = await _client.post('/api/v3/liveness/verify', token: token, body: {
      'image': imageBase64,
    });
    return LivenessResult.fromJson(response);
  }

  // 8. Comparacion facial 1:1
  Future<FaceComparison> compareFaces(
    String token, {
    required String image1Base64,
    required String image2Base64,
  }) async {
    if (_useMock) return _mockFaceComparison();

    final response = await _client.post('/api/v2/oto/verify', token: token, body: {
      'image_1': image1Base64,
      'image_2': image2Base64,
    });
    return FaceComparison.fromJson(response);
  }

  // 9. Finalizar sesion
  Future<void> finishSession(String token) async {
    if (_useMock) return;
    await _client.post('/api/v1/kyc/session/finish', token: token);
  }

  // ── Flujo completo mock ──

  /// Ejecuta el flujo KYC completo en modo mock con callbacks de progreso
  Future<Map<String, dynamic>> runFullFlow({
    required String frontBase64,
    required String backBase64,
    required String selfieBase64,
    void Function(String step, bool success)? onStepComplete,
  }) async {
    // 1. Crear sesion
    var session = await createSession(name: 'SAYO KYC');
    session = await exchangeToken(session);
    final token = session.accessToken ?? '';

    // 2. Registrar ubicacion (mock: CDMX)
    await registerLocation(token, 19.4326, -99.1332);

    // 3. Verificar documento
    await Future.delayed(const Duration(milliseconds: 800));
    final docResult = await verifyDocument(token, frontBase64: frontBase64, backBase64: backBase64);
    onStepComplete?.call('document_verify', docResult.isApproved);

    // 4. Extraer datos
    await Future.delayed(const Duration(milliseconds: 600));
    final extractedData = await extractData(token, frontBase64: frontBase64, backBase64: backBase64);
    onStepComplete?.call('data_extract', extractedData.curp != null);

    // 5. Listas negras
    await Future.delayed(const Duration(milliseconds: 700));
    final blacklist = await investigateBlacklist(
      token,
      curp: extractedData.curp ?? 'MOCK000000HDFRRN09',
      fullName: extractedData.fullName ?? 'USUARIO DE PRUEBA',
    );
    final blacklistOk = blacklist.every((r) => r.isValid);
    onStepComplete?.call('blacklist', blacklistOk);

    // 6. Liveness
    await Future.delayed(const Duration(milliseconds: 900));
    final liveness = await verifyLiveness(token, imageBase64: selfieBase64);
    onStepComplete?.call('liveness', liveness.isAlive);

    // 7. Comparacion facial
    await Future.delayed(const Duration(milliseconds: 600));
    final faceMatch = await compareFaces(
      token,
      image1Base64: extractedData.faceBase64 ?? frontBase64,
      image2Base64: selfieBase64,
    );
    onStepComplete?.call('face_match', faceMatch.isSamePerson);

    // 8. Finalizar
    await finishSession(token);

    final allPassed = docResult.isApproved && blacklistOk && liveness.isAlive && faceMatch.isSamePerson;

    return {
      'approved': allPassed,
      'document': docResult,
      'extracted_data': extractedData,
      'blacklist': blacklist,
      'liveness': liveness,
      'face_comparison': faceMatch,
    };
  }

  // ── Mock Data ──

  KycSession _mockSession() {
    return const KycSession(
      sessionUrl: 'https://sandbox.jaak.ai/kyc/mock',
      shortKey: 'MOCK-KEY-123',
    );
  }

  DocumentVerification _mockDocVerification() {
    return const DocumentVerification(
      evaluation: 'APPROVED',
      documentType: 'INE',
      validations: {'front_valid': true, 'back_valid': true, 'mrz_valid': true},
    );
  }

  ExtractedData _mockExtractedData() {
    return const ExtractedData(
      fullName: 'JUAN CARLOS PEREZ LOPEZ',
      curp: 'PELJ900101HDFRRN09',
      address: 'AV. REFORMA 222, COL. JUAREZ, CDMX',
      birthDate: '01/01/1990',
      gender: 'H',
      documentNumber: '1234567890123',
    );
  }

  List<BlacklistResult> _mockBlacklistResults() {
    return const [
      BlacklistResult(organization: 'RENAPO', foundInService: true, mustBeFound: true),
      BlacklistResult(organization: 'OFAC', foundInService: false, mustBeFound: false),
      BlacklistResult(organization: 'Interpol', foundInService: false, mustBeFound: false),
      BlacklistResult(organization: 'INE', foundInService: true, mustBeFound: true),
    ];
  }

  LivenessResult _mockLiveness() {
    return const LivenessResult(evaluation: 'APPROVED', score: 0.98);
  }

  FaceComparison _mockFaceComparison() {
    return const FaceComparison(score: 0.95, isSamePerson: true);
  }
}
