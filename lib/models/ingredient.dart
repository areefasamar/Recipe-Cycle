class Ingredient {
  final String name;
  final String slug;
  final String category;
  final List<String> aliases;
  final bool isStaple;

  const Ingredient({
    required this.name,
    required this.slug,
    required this.category,
    required this.aliases,
    required this.isStaple,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      slug: json['slug'] as String,
      category: json['category'] as String,
      // aliases may be absent in older data, so default to empty list
      aliases: (json['aliases'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      isStaple: json['isStaple'] as bool? ?? false,
    );
  }
}
