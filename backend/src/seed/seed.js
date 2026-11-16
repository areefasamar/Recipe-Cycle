const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
const fs = require('fs');
const mongoose = require('mongoose');
const connectDB = require('../config/db');
const Ingredient = require('../models/Ingredient');
const Recipe = require('../models/Recipe');

const seedData = async () => {
  try {
    // Read JSON files
    const rawIngredients = JSON.parse(
      fs.readFileSync(path.join(__dirname, 'ingredients.json'), 'utf-8')
    );
    const rawRecipes = JSON.parse(
      fs.readFileSync(path.join(__dirname, 'recipes.json'), 'utf-8')
    );

    // Remove any "id" field so MongoDB assigns fresh ObjectIds
    const ingredients = rawIngredients.map(({ id, ...rest }) => rest);
    const recipes = rawRecipes.map(({ id, ...rest }) => rest);

    // Check that every recipe slug exists in the ingredients
    const ingredientSlugs = new Set(ingredients.map((i) => i.slug));
    for (const recipe of recipes) {
      for (const slug of recipe.ingredients) {
        if (!ingredientSlugs.has(slug)) {
          console.error(`Error: Unknown ingredient slug "${slug}" in recipe "${recipe.title}"`);
          process.exit(1);
        }
      }
    }

    // Connect to MongoDB Atlas
    await connectDB();

    // deleteMany and insertMany so running twice never duplicates
    await Ingredient.deleteMany({});
    await Recipe.deleteMany({});

    await Ingredient.insertMany(ingredients);
    await Recipe.insertMany(recipes);

    console.log(`Seeded ${ingredients.length} ingredients and ${recipes.length} recipes successfully.`);
    await mongoose.connection.close();
    process.exit(0);
  } catch (err) {
    console.error('Seeding failed:', err.message);
    process.exit(1);
  }
};

seedData();
