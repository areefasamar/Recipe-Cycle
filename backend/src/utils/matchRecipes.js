/**
 * Matches recipes against available ingredients.
 * Pure function: no database calls.
 *
 * @param {string[]} userSlugs - List of ingredient slugs the user has.
 * @param {Array} recipes - List of recipe objects.
 * @param {string[]} stapleSlugs - List of staple ingredient slugs (always available).
 * @returns {Array} Filtered (>=40%), sorted (matchPercent desc, missing asc), capped (<=20) matches.
 */
function matchRecipes(userSlugs, recipes, stapleSlugs) {
  const stapleSet = new Set(stapleSlugs || []);
  const available = new Set([...(userSlugs || []), ...stapleSet]);
  const results = [];

  for (const recipe of recipes) {
    // Exclude staples from percentage math and missing list so salt never counts against a recipe
    const nonStaple = (recipe.ingredients || []).filter((s) => !stapleSet.has(s));

    // Avoid division by zero if a recipe only has staples
    if (nonStaple.length === 0) continue;

    const matched = nonStaple.filter((s) => available.has(s));
    const missing = nonStaple.filter((s) => !available.has(s));

    const matchPercent = Math.round((matched.length / nonStaple.length) * 100);

    // Section 6: Only return recipes with matchPercent >= 40
    if (matchPercent < 40) continue;

    results.push({
      recipe,
      matchPercent,
      matched,
      missing,
    });
  }

  // Sort: higher matchPercent first; on ties, fewer missing first
  results.sort((a, b) => {
    if (b.matchPercent !== a.matchPercent) {
      return b.matchPercent - a.matchPercent;
    }
    return a.missing.length - b.missing.length;
  });

  // Section 6: Cap the response at 20 recipes
  return results.slice(0, 20);
}

module.exports = matchRecipes;
