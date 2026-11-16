const mongoose = require('mongoose');
const Recipe = require('../models/Recipe');
const Ingredient = require('../models/Ingredient');
const matchRecipes = require('../utils/matchRecipes');

// GET /api/recipes - Returns all recipes without matching
const getRecipes = async (req, res) => {
  try {
    const recipes = await Recipe.find();
    res.json(recipes);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET /api/recipes/:id - Returns one recipe by ID
const getRecipeById = async (req, res) => {
  const { id } = req.params;

  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).json({ message: 'Malformed id' });
  }

  try {
    const recipe = await Recipe.findById(id);
    if (!recipe) {
      return res.status(404).json({ message: 'Recipe not found' });
    }
    res.json(recipe);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// POST /api/recipes/match - Returns matched recipes ranked by matchPercent
const matchRecipesHandler = async (req, res) => {
  const { ingredients } = req.body;

  if (!Array.isArray(ingredients) || ingredients.length === 0) {
    return res
      .status(400)
      .json({ message: 'ingredients must be a non-empty array' });
  }

  try {
    // Retrieve all staple slugs to treat as available without penalizing recipes
    const stapleIngredients = await Ingredient.find({ isStaple: true }, 'slug');
    const stapleSlugs = stapleIngredients.map((i) => i.slug);

    const recipes = await Recipe.find();

    const matches = matchRecipes(ingredients, recipes, stapleSlugs);
    res.json(matches);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = {
  getRecipes,
  getRecipeById,
  matchRecipes: matchRecipesHandler,
};
