import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/app_user.dart';
import 'api_service.dart';

class AuthService {
  final String _baseUrl;
  final http.Client _client;

  AuthService({String? baseUrl, http.Client? client})
      : _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _client = client ?? http.Client();

  String _extractErrorMessage(http.Response response, String fallback) {
    try {
      final dynamic body = json.decode(response.body);
      if (body is Map && body['message'] is String) {
        return body['message'] as String;
      }
    } catch (_) {}
    return fallback;
  }

  /// POST /api/auth/register
  Future<({String token, AppUser user})> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/auth/register');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 201) {
        throw ApiException(
          _extractErrorMessage(
            response,
            'Registration failed (status: ${response.statusCode})',
          ),
          response.statusCode,
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      return (token: token, user: user);
    } on TimeoutException {
      throw const ApiException('Request timed out. Please check your connection.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// POST /api/auth/login
  Future<({String token, AppUser user})> login(
    String email,
    String password,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/auth/login');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ApiException(
          _extractErrorMessage(
            response,
            'Login failed (status: ${response.statusCode})',
          ),
          response.statusCode,
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      return (token: token, user: user);
    } on TimeoutException {
      throw const ApiException('Request timed out. Please check your connection.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// GET /api/auth/me
  Future<AppUser> me(String token) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/auth/me');
      final response = await _client
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ApiException(
          _extractErrorMessage(
            response,
            'Failed to fetch user (status: ${response.statusCode})',
          ),
          response.statusCode,
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return AppUser.fromJson(data['user'] as Map<String, dynamic>);
    } on TimeoutException {
      throw const ApiException('Request timed out. Please check your connection.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
}
