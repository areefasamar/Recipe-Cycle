const mongoose = require('mongoose');

const recipeSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    default: '',
  },
  ingredients: {
    type: [String],
    required: true,
  },
  steps: {
    type: [String],
    required: true,
  },
  prepMinutes: {
    type: Number,
  },
  servings: {
    type: Number,
  },
  tags: {
    type: [String],
    default: [],
  },
});

// Transform _id to id and remove __v for Flutter client compatibility
recipeSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('Recipe', recipeSchema);
