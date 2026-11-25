import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/project.dart';

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  static const _timeout = Duration(seconds: 20);

  Uri _uri(String path) =>
      Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}$path');

  Map<String, String> _headers([String? token]) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
    if (token != null) 'Authorization': 'Token $token',
  };

  Future<List<Project>> getProjects() async {
    final response = await _client
        .get(_uri('/api/v1/projects/'), headers: _headers())
        .timeout(_timeout);
    _ensureSuccess(response);
    return (jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>)
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _client
        .post(
          _uri('/api/v1/projects/'),
          headers: _headers(token),
          body: jsonEncode(project.toJson()),
        )
        .timeout(_timeout);
    _ensureSuccess(response);
    return Project.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _client
        .post(
          _uri('/api/v1/auth/token/'),
          headers: _headers(),
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(_timeout);
    _ensureSuccess(response);
    final token =
        (jsonDecode(response.body) as Map<String, dynamic>)['token'] as String;
    if (token.isEmpty) {
      throw const FormatException('Empty authentication token');
    }
    return token;
  }

  Future<void> logout({required String token}) async {
    final response = await _client
        .post(_uri('/api/v1/auth/logout/'), headers: _headers(token))
        .timeout(_timeout);
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    // Never expose Django debug pages or raw response bodies in the UI.
    final message = switch (response.statusCode) {
      400 => 'Data tidak valid. Periksa isian Anda.',
      401 => 'Sesi berakhir. Silakan login kembali.',
      403 => 'Akun ini tidak memiliki izin untuk menambah proyek.',
      _ => 'Permintaan gagal. Silakan coba lagi.',
    };
    throw ApiException(response.statusCode, message);
  }

  void close() => _client.close();
}
