import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? body;

  const ApiException(this.statusCode, this.message, [this.body]);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final String baseUrl;
  final String? apiKey;
  final Duration timeout;

  ApiClient({
    required this.baseUrl,
    this.apiKey,
    this.timeout = const Duration(seconds: 30),
  });

  Map<String, String> _headers({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    } else if (apiKey != null && apiKey!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    String? token,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers(token: token)).timeout(timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http
        .post(uri, headers: _headers(token: token), body: body != null ? jsonEncode(body) : null)
        .timeout(timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http
        .put(uri, headers: _headers(token: token), body: body != null ? jsonEncode(body) : null)
        .timeout(timeout);
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) as Map<String, dynamic> : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = switch (response.statusCode) {
      400 => body['message'] as String? ?? 'Solicitud invalida',
      401 => 'No autorizado — verifica tu API key',
      403 => 'Acceso denegado',
      404 => 'Recurso no encontrado',
      422 => body['message'] as String? ?? 'Datos invalidos',
      429 => 'Demasiadas solicitudes — intenta mas tarde',
      _ => 'Error del servidor (${response.statusCode})',
    };

    throw ApiException(response.statusCode, message, body);
  }
}
