# Recipe Cycle: Build Spec

Read this whole file once before writing any code. Then work on ONE milestone at a time (see section 10).

## 1. What we are building

Recipe Cycle is a mobile app that reduces food waste. The user ticks the ingredients they already have at home. The app returns recipes they can cook, ranked by how many ingredients they already have, and shows what is missing.

This is a learning project for the Flutter, Dart, Node.js, Express and MongoDB stack. It is still a real, working MVP. Code must be simple and readable, not clever.

## 2. Hard constraints

- Everything must run on free tiers. No paid services, no paid APIs, no credit card.
- Database: MongoDB Atlas free M0 cluster (512 MB). Seed data must stay small.
- Backend runs locally during development. No hosting setup in this phase.
- No AI/LLM features in the app. Matching is plain set logic.
- No authentication in the MVP. No user accounts.
- Do not add packages that are not listed in section 3. Ask first.
- Do not refactor files that already work.

## 3. Tech stack

| Layer | Choice |
|---|---|
| Mobile app | Flutter (stable), Dart |
| State management | `provider` |
| HTTP | `http` package |
| Local storage | `shared_preferences` (stores the user's pantry on device) |
| Backend | Node.js (LTS), Express |
| Database | MongoDB Atlas M0 via `mongoose` |
| Backend extras | `cors`, `dotenv`, `nodemon` (dev only) |

Targets: Android and Web (Chrome). No iOS, Windows, Linux or macOS.

## 4. Repo layout

Repo root is `Recipe-Cycle`.

```
Recipe-Cycle/
  README.md
  docs/
    ARCHITECTURE.md        (this file)
  backend/
    package.json
    .env                   (never commit; holds MONGODB_URI and PORT)
    .env.example           (committed; placeholder values only)
    .gitignore             (node_modules, .env)
    src/
      server.js            (app setup, middleware, route mounting, listen)
      config/db.js         (mongoose connect)
      models/
        Ingredient.js
        Recipe.js
      routes/
        ingredients.js
        recipes.js
      controllers/
        ingredientController.js
        recipeController.js
      utils/
        matchRecipes.js    (pure function, easy to read and test)
      seed/
        seed.js            (run once: node src/seed/seed.js)
        ingredients.json
        recipes.json
  app/                     (Flutter project, package name: recipe_cycle)
    pubspec.yaml
    lib/
      main.dart
      config/api_config.dart
      models/
        ingredient.dart
        recipe.dart
        recipe_match.dart
      services/
        api_service.dart       (all HTTP calls live here only)
        pantry_storage.dart    (shared_preferences wrapper)
      providers/
        ingredient_provider.dart
        pantry_provider.dart
        recipe_provider.dart
      screens/
        ingredient_checklist_screen.dart
        recipe_results_screen.dart
        recipe_detail_screen.dart
      widgets/
        ingredient_tile.dart
        recipe_card.dart
        search_bar_field.dart
        state_views.dart       (loading, error, empty views)
```

## 5. Data models (MongoDB)

### Ingredient
```
{
  name:      String, required          // "Onion"
  slug:      String, required, unique  // "onion" (lowercase, hyphenated, this is the matching key)
  category:  String, required          // one of the categories below
  aliases:   [String]                  // ["pyaz"], used by the search bar only
  isStaple:  Boolean, default false    // salt, water, cooking oil, etc.
}
```

Categories (fixed list): `Vegetables`, `Fruits`, `Dairy and Eggs`, `Meat and Fish`, `Grains and Flour`, `Lentils and Beans`, `Spices`, `Oils and Condiments`, `Other`.

Include everyday Pakistani kitchen items in the seed list (atta, daal varieties, haldi, zeera, garam masala, dhania, adrak, lehsan, pyaz, tamatar, etc.) along with common global ones. Aim for roughly 80 to 100 ingredients so most home kitchens are covered.

### Recipe
```
{
  title:        String, required
  description:  String
  ingredients:  [String], required   // array of ingredient SLUGS
  steps:        [String], required
  prepMinutes:  Number
  servings:     Number
  tags:         [String]             // "vegetarian", "quick", "desi", etc.
}
```

Recipes reference ingredients by slug string, not ObjectId. This keeps matching and seed files simple.

Seed 12 to 15 recipes only, mixing desi and simple global dishes. Every slug used in a recipe must exist in `ingredients.json`. The seed script must fail loudly if it finds an unknown slug.

## 6. API contract

Base path: `/api`. All responses are JSON. Add `cors()` so Flutter Web can call it.

### GET /api/health
`200 { "status": "ok" }`

### GET /api/ingredients
Returns all ingredients, sorted by category then name.
```
200 [ { "_id", "name", "slug", "category", "aliases", "isStaple" }, ... ]
```

### GET /api/recipes
Returns all recipes (no matching). Used for debugging and a future browse screen.

### GET /api/recipes/:id
Returns one recipe. `404 { "message": "Recipe not found" }` if missing. `400` for a malformed id.

### POST /api/recipes/match
Request:
```
{ "ingredients": ["onion", "tomato", "rice"] }
```
Response (sorted by `matchPercent` descending, then fewer missing first):
```
200 [
  {
    "recipe": { ...full recipe... },
    "matchPercent": 80,
    "matched": ["onion", "tomato"],
    "missing": ["garlic"]
  }
]
```
Rules:
- Empty or missing `ingredients` returns `400 { "message": "ingredients must be a non-empty array" }`.
- Only return recipes with `matchPercent >= 40`.
- Cap the response at 20 recipes.

## 7. Matching logic (`utils/matchRecipes.js`)

Pure function: `matchRecipes(userSlugs, recipes, stapleSlugs)`.

1. Treat staples as always available. Add `stapleSlugs` to the user's set.
2. For each recipe, split its ingredients into `matched` (in the user's set) and `missing`.
3. Exclude staples from the percentage math and from `missing`, so "salt" never counts against a recipe.
4. `matchPercent = round(matched.length / (matched.length + missing.length) * 100)`.
5. Filter, sort and cap as described in section 6.

Keep this file free of database code so it is easy to read and explain.

## 8. Flutter architecture

Simple layered structure, one direction of dependency:

`screens/widgets -> providers -> services -> backend`

- **Models**: plain Dart classes with `fromJson`. No logic beyond parsing.
- **services/api_service.dart**: the only place that calls `http`. Returns models. Throws a simple `ApiException(message)` on failure.
- **services/pantry_storage.dart**: saves and loads the pantry (list of slugs) with `shared_preferences`.
- **Providers** (`ChangeNotifier`):
  - `IngredientProvider`: loads ingredients, holds search text, exposes ingredients grouped by category and filtered by search (match name and aliases, case-insensitive).
  - `PantryProvider`: the set of selected slugs. `toggle(slug)`, `clear()`, `removeAll(slugs)`. Loads from and saves to local storage on every change.
  - `RecipeProvider`: calls the match endpoint using the pantry, holds `loading / error / results`.
- **Screens**:
  1. `IngredientChecklistScreen`: search bar on top, ingredients grouped by category in collapsible sections (`ExpansionTile`), a checkbox per ingredient, a selected-count chip, and a bottom "Find recipes" button (disabled when nothing is selected).
  2. `RecipeResultsScreen`: list of `RecipeCard`s showing title, match percent, "you have X of Y", and the first missing ingredients.
  3. `RecipeDetailScreen`: ingredients split into "You have" and "You need", then numbered steps. A "I cooked this" button removes the matched ingredients from the pantry and returns to the checklist.
- **Shared views** (`state_views.dart`): loading spinner, error message with a Retry button, empty message. Every screen that loads data must use them.
- **Navigation**: plain `Navigator.push`. No routing package.
- **Theme**: Material 3, one seed color, light theme only. Do not spend effort on custom design.

### API base URL (`config/api_config.dart`)
- Web (Chrome): `http://localhost:3000`
- Physical Android phone over USB: run `adb reverse tcp:3000 tcp:3000`, then `http://localhost:3000` works.
- Android emulator: `http://10.0.2.2:3000`
Pick with `kIsWeb` and a single constant the developer can edit. For Android debug builds only, allow cleartext HTTP in `android/app/src/debug/AndroidManifest.xml` (`android:usesCleartextTraffic="true"`).

## 9. Backend environment

`backend/.env`:
```
PORT=3000
MONGODB_URI=<Atlas connection string>
```
`.env` must be listed in `backend/.gitignore`. The GitHub repo is public. Never print, log or commit the connection string. Commit `.env.example` with placeholder values.

## 10. Milestones

Do one milestone per session. Stop when its acceptance checks pass. Do not start the next one.

**M1: Backend skeleton**
- `npm init`, install the listed packages, add `dev` script with nodemon.
- `server.js`, `config/db.js`, `GET /api/health`.
- Accept: `npm run dev` connects to Atlas and `/api/health` returns ok.

**M2: Models and seed**
- `Ingredient` and `Recipe` models, `ingredients.json`, `recipes.json`, `seed.js`.
- Accept: running the seed twice does not create duplicates, and an unknown slug in a recipe makes the seed fail with a clear message.

**M3: Read and match endpoints**
- Routes, controllers and `matchRecipes.js` as specified.
- Accept: the endpoints behave as in section 6 when called from a browser or Postman. Include 3 example curl commands in `backend/README.md`.

**M4: Flutter foundation and checklist**
- Create providers, services, models, `api_config.dart`, checklist screen.
- Accept: ingredients load from the backend and show grouped by category, search finds "pyaz" and "onion", ticking updates the count, pantry survives an app restart.

**M5: Results and detail screens**
- `RecipeProvider`, results screen, detail screen.
- Accept: ticking a few ingredients and tapping "Find recipes" shows ranked results with correct match percentages and missing lists.

**M6: Cooked it**
- "I cooked this" button removes matched ingredients from the pantry.
- Accept: after pressing it, those ingredients are unticked on the checklist.

**M7: Polish and docs**
- Loading, error and empty states everywhere. Root `README.md` with setup steps for both halves.
- Accept: with the backend stopped, the app shows the error view with Retry instead of crashing.

## 11. Out of scope for now

Login or accounts, cloud deployment, image uploads, recipe creation by users, AI substitutions, notifications, expiry dates, iOS, dark theme, unit tests beyond `matchRecipes`.

## 12. Working rules for the agent (save quota)

The developer is on a free plan with a weekly limit, so be economical.

- One milestone per session. Do not run ahead.
- Do not launch emulators, browsers or screenshot loops to verify. The developer runs `flutter run` and `npm run dev` and reports back.
- Write each file once. No "polish passes" or rewriting files that already work.
- Keep replies short: list the files changed and the command to run next.
- Keep code beginner-readable. Add a one-line comment above non-obvious code explaining WHY, not what.
- If something in this spec is ambiguous, pick the simplest option and note it in one line.
