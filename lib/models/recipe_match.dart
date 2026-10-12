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
}
