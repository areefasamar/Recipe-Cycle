import 'package:flutter/material.dart';
import '../models/recipe_match.dart';
import '../theme/app_theme.dart';

/// Summary card shown in the results list.
class RecipeCard extends StatelessWidget {
  final RecipeMatch match;
  final VoidCallback onTap;

  const RecipeCard({super.key, required this.match, required this.onTap});

  Color _getMatchColor(int percent) {
    if (percent >= 80) return AppTheme.primary;
    if (percent >= 60) return AppTheme.accent;
    return Colors.amber.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final total = match.matched.length + match.missing.length;
    final matchColor = _getMatchColor(match.matchPercent);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceM,
        vertical: AppTheme.spaceS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: const Color(0xFFEDE8DF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: Title & Circular Match Ring ───────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: 'recipe-title-${match.recipe.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                match.recipe.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spaceXS),
                          Text(
                            'You have ${match.matched.length} of $total ingredients',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceM),
                    // Circular Match Ring
                    Hero(
                      tag: 'recipe-match-${match.recipe.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 54,
                              height: 54,
                              child: CircularProgressIndicator(
                                value: match.matchPercent / 100,
                                strokeWidth: 5,
                                backgroundColor: matchColor.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(matchColor),
                              ),
                            ),
                            Text(
                              '${match.matchPercent}%',
                              style: TextStyle(
                                fontSize: 13,
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

                // ── Info Chips: Prep Time & Servings ───────────────────
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.timer_outlined,
                      label: '${match.recipe.prepMinutes} min',
                    ),
                    const SizedBox(width: AppTheme.spaceS),
                    _InfoChip(
                      icon: Icons.people_outline,
                      label: '${match.recipe.servings} servings',
                    ),
                  ],
                ),

                // ── Missing Ingredients Chips ──────────────────────────
                if (match.missing.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spaceM),
                  Wrap(
                    spacing: AppTheme.spaceXS,
                    runSpacing: AppTheme.spaceXS,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Missing: ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                      ),
                      ...match.missing.map((slug) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.accent.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            slug.replaceAll('-', ' '),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accent,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EDE4),
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
