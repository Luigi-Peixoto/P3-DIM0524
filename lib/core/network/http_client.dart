// lib/core/network/http_client.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class HttpClient {
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final params = {'language': AppConfig.language, ...?queryParams};

    final uri = Uri.parse(
      '${AppConfig.baseUrl}$endpoint',
    ).replace(queryParameters: params);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${AppConfig.apiKey}',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro na requisição: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${AppConfig.apiKey}',
        'accept': 'application/json',
        'content-type': 'application/json',
      },
      body: jsonEncode(body ?? {}),
    );

    return jsonDecode(response.body);
  }
}
