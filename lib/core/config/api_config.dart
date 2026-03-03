class ApiConfig {
  static const bool useSandbox = true;

  // TAPI — Pago de servicios
  static const String tapiBaseUrl = 'https://api.tapi.la';
  static const String tapiApiKey = ''; // Configurar con API key de TAPI

  // JAAK — KYC
  static String get jaakBaseUrl => useSandbox
      ? 'https://sandbox.api.jaak.ai'
      : 'https://services.api.jaak.ai';
  static const String jaakApiKey = ''; // Configurar con API key de JAAK

  static bool get isTapiConfigured => tapiApiKey.isNotEmpty;
  static bool get isJaakConfigured => jaakApiKey.isNotEmpty;
}
