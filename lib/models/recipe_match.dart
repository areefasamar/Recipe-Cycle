import 'recipe.dart';

/// Holds one recipe together with its match result for the current pantry.
class RecipeMatch {
  final Recipe recipe;
  final int matchPercent;
  final List<String> matched;
  final List<String> missing;

  const RecipeMatch({
    required this.recipe,
    required this.matchPercent,
    required this.matched,
    required this.missing,
  });

  factory RecipeMatch.fromJson(Map<String, dynamic> json) {
    return RecipeMatch(
      recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
      matchPercent: (json['matchPercent'] as num).toInt(),
      matched: (json['matched'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      missing: (json['missing'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}
