import 'package:flutter/material.dart';
import '../models/recipe_match.dart';

/// Summary card shown in the results list.
class RecipeCard extends StatelessWidget {
  final RecipeMatch match;
  final VoidCallback onTap;

  const RecipeCard({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final total = match.matched.length + match.missing.length;
    // Only show up to 3 missing ingredients to keep the card compact
    final previewMissing = match.missing.take(3).toList();
    final extraMissing = match.missing.length - previewMissing.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title row with match percent badge ──────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(match.recipe.title,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const SizedBox(width: 8),
                  _MatchBadge(percent: match.matchPercent),
                ],
              ),

              const SizedBox(height: 6),

              // ── "You have X of Y" line ──────────────────────────────
              Text(
                'You have ${match.matched.length} of $total ingredients',
                style: Theme.of(context).textTheme.bodySmall,
              ),

              // ── Missing ingredients preview ─────────────────────────
              if (match.missing.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Missing: ${previewMissing.join(', ')}'
                  '${extraMissing > 0 ? ' +$extraMissing more' : ''}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Small colored circle showing the match percentage.
class _MatchBadge extends StatelessWidget {
  final int percent;

  const _MatchBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    // Green for high match, amber for partial
    final color = percent >= 80
        ? Colors.green
        : percent >= 60
            ? Colors.amber.shade700
            : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        '$percent%',
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
