import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/ingredient.dart';
import '../models/recipe_match.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  final String _baseUrl;
  final http.Client _client;

  ApiService({String? baseUrl, http.Client? client})
      : _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _client = client ?? http.Client();

  /// GET /api/ingredients
  /// Fetches the full sorted list of ingredients from the backend.
  Future<List<Ingredient>> fetchIngredients() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/ingredients');
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ApiException(
          'Failed to load ingredients (status: ${response.statusCode})',
        );
      }

      final dynamic data = json.decode(response.body);
      if (data is! List) {
        throw const ApiException('Invalid response format for ingredients');
      }

      return data
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw const ApiException('Request timed out while loading ingredients');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to load ingredients: $e');
    }
  }

  /// POST /api/recipes/match
  /// Matches the provided ingredient slugs against all recipes.
  Future<List<RecipeMatch>> matchRecipes(List<String> slugs) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/recipes/match');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'ingredients': slugs}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ApiException(
          'Failed to match recipes (status: ${response.statusCode})',
        );
      }

      final dynamic data = json.decode(response.body);
      if (data is! List) {
        throw const ApiException('Invalid response format for matched recipes');
      }

      return data
          .map((e) => RecipeMatch.fromJson(e as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw const ApiException('Request timed out while matching recipes');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to match recipes: $e');
    }
  }
}
