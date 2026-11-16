class HistoryEntry {
  final String recipeId;
  final String title;
  final DateTime cookedAt;

  const HistoryEntry({
    required this.recipeId,
    required this.title,
    required this.cookedAt,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      recipeId: json['recipeId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      cookedAt: DateTime.tryParse(json['cookedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'title': title,
      'cookedAt': cookedAt.toIso8601String(),
    };
  }
}
