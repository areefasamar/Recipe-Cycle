const mongoose = require('mongoose');

const CATEGORIES = [
  'Vegetables',
  'Fruits',
  'Dairy and Eggs',
  'Meat and Fish',
  'Grains and Flour',
  'Lentils and Beans',
  'Spices',
  'Oils and Condiments',
  'Other',
];

const ingredientSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  slug: {
    type: String,
    required: true,
    unique: true,
  },
  category: {
    type: String,
    required: true,
    enum: CATEGORIES,
  },
  aliases: {
    type: [String],
    default: [],
  },
  isStaple: {
    type: Boolean,
    default: false,
  },
});

// Transform _id to id and remove __v for Flutter client compatibility
ingredientSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('Ingredient', ingredientSchema);
