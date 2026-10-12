import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_match.dart';
import '../providers/pantry_provider.dart';
import '../theme/app_theme.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeMatch match;

  const RecipeDetailScreen({super.key, required this.match});

  Color _getMatchColor(int percent) {
    if (percent >= 80) return AppTheme.primary;
    if (percent >= 60) return AppTheme.accent;
    return Colors.amber.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final recipe = match.recipe;
    final matchColor = _getMatchColor(match.matchPercent);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceM,
          vertical: AppTheme.spaceS,
        ),
        children: [
          // ── Header Section with Hero animation ──────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'recipe-title-${recipe.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          recipe.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: const Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                    if (recipe.description.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.spaceS),
                      Text(
                        recipe.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spaceM),
              // Match Ring
              Hero(
                tag: 'recipe-match-${recipe.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          value: match.matchPercent / 100,
                          strokeWidth: 6,
                          backgroundColor: matchColor.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(matchColor),
                        ),
                      ),
                      Text(
                        '${match.matchPercent}%',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: matchColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spaceM),

          // ── Info Chips: Prep Time & Servings ─────────────────────────
          Row(
            children: [
              _InfoChip(
                icon: Icons.timer_outlined,
                label: '${recipe.prepMinutes} min',
              ),
              const SizedBox(width: AppTheme.spaceS),
              _InfoChip(
                icon: Icons.people_outline,
                label: '${recipe.servings} servings',
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spaceL),

          // ── "You have" Ingredients as Green Chips ────────────────────
          Text(
            'You have (${match.matched.length})',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
          ),
          const SizedBox(height: AppTheme.spaceS),
          Wrap(
            spacing: AppTheme.spaceS,
            runSpacing: AppTheme.spaceS,
            children: match.matched.map((slug) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      slug.replaceAll('-', ' '),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          // ── "You need" Ingredients as Orange Chips ───────────────────
          if (match.missing.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spaceL),
            Text(
              'You need (${match.missing.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accent,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceS),
            Wrap(
              spacing: AppTheme.spaceS,
              runSpacing: AppTheme.spaceS,
              children: match.missing.map((slug) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                    border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 16,
                        color: AppTheme.accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        slug.replaceAll('-', ' '),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: AppTheme.spaceXL),

          // ── Steps as Numbered Cards ──────────────────────────────────
          Text(
            'Steps',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A1A),
                ),
          ),
          const SizedBox(height: AppTheme.spaceM),
          ...recipe.steps.asMap().entries.map((entry) {
            final index = entry.key;
            final stepText = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spaceM),
              padding: const EdgeInsets.all(AppTheme.spaceM),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                border: Border.all(color: const Color(0xFFEDE8DF)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceM),
                  Expanded(
                    child: Text(
                      stepText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                            color: const Color(0xFF2C2C2C),
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: AppTheme.spaceL),

          // ── "I cooked this" Button ────────────────────────────────────
          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
              ),
            ),
            onPressed: () => _onCooked(context),
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text(
              'I cooked this!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: AppTheme.spaceXL),
        ],
      ),
    );
  }

  Future<void> _onCooked(BuildContext context) async {
    await context.read<PantryProvider>().removeAll(match.matched);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nice! Pantry updated.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EDE4),
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
