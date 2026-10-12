import 'package:flutter/foundation.dart';
import '../models/recipe_match.dart';
import '../services/local_data_service.dart';

/// Runs the match query and exposes loading / error / results to the UI.
class RecipeProvider extends ChangeNotifier {
  final LocalDataService _service;

  RecipeProvider(this._service);

  bool isLoading = false;
  String? error;
  List<RecipeMatch> results = [];

  /// Call this when the user taps "Find Recipes" with their current pantry slugs.
  Future<void> match(List<String> slugs) async {
    isLoading = true;
    error = null;
    results = [];
    notifyListeners();

    try {
      results = await _service.matchRecipes(slugs);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
