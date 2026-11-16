const Ingredient = require('../models/Ingredient');

// GET /api/ingredients - Returns all ingredients sorted by category then name
const getIngredients = async (req, res) => {
  try {
    const ingredients = await Ingredient.find().sort({ category: 1, name: 1 });
    res.json(ingredients);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = {
  getIngredients,
};
