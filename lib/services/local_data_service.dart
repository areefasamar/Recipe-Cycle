import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/recipe_match.dart';

/// Loads JSON from the assets bundle and runs matching locally.
/// This replaces API calls while the backend is not yet connected.
class LocalDataService {
  Future<List<Ingredient>> fetchIngredients() async {
    final raw = await rootBundle.loadString('assets/data/ingredients.json');
    final list = json.decode(raw) as List<dynamic>;
    return list.map((e) => Ingredient.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Recipe>> _fetchRecipes() async {
    final raw = await rootBundle.loadString('assets/data/recipes.json');
    final list = json.decode(raw) as List<dynamic>;
    return list.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Mirrors the matching logic from ARCHITECTURE.md section 7, written in Dart.
  Future<List<RecipeMatch>> matchRecipes(List<String> userSlugs) async {
    final ingredients = await fetchIngredients();
    final recipes = await _fetchRecipes();

    // Build a set of slugs that are always available (staples + user's pantry)
    final stapleSlugs = ingredients
        .where((i) => i.isStaple)
        .map((i) => i.slug)
        .toSet();
    final available = {...stapleSlugs, ...userSlugs};

    final results = <RecipeMatch>[];

    for (final recipe in recipes) {
      // Only non-staple ingredients count toward the percentage
      final nonStaple = recipe.ingredients.where((s) => !stapleSlugs.contains(s)).toList();

      final matched = nonStaple.where((s) => available.contains(s)).toList();
      final missing = nonStaple.where((s) => !available.contains(s)).toList();

      // Avoid division by zero for a recipe that is all staples
      if (nonStaple.isEmpty) continue;

      final matchPercent = (matched.length / nonStaple.length * 100).round();

      // Section 6: only include recipes >= 40 % match
      if (matchPercent < 40) continue;

      results.add(RecipeMatch(
        recipe: recipe,
        matchPercent: matchPercent,
        matched: matched,
        missing: missing,
      ));
    }

    // Sort: higher matchPercent first; on ties, fewer missing first
    results.sort((a, b) {
      final cmp = b.matchPercent.compareTo(a.matchPercent);
      if (cmp != 0) return cmp;
      return a.missing.length.compareTo(b.missing.length);
    });

    // Section 6: cap at 20 results
    return results.take(20).toList();
  }
}
