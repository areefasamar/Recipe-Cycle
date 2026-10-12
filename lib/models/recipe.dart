class Recipe {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients; // list of slugs
  final List<String> steps;
  final int prepMinutes;
  final int servings;
  final List<String> tags;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.prepMinutes,
    required this.servings,
    required this.tags,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      steps: (json['steps'] as List<dynamic>).map((e) => e as String).toList(),
      prepMinutes: (json['prepMinutes'] as num? ?? 0).toInt(),
      servings: (json['servings'] as num? ?? 1).toInt(),
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }
}
