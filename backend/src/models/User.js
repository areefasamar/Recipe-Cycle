const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
  },
  passwordHash: {
    type: String,
    required: true,
  },
});

// Transform document to JSON for client consumption
userSchema.set('toJSON', {
  transform: (doc, ret) => {
    // Convert _id to string id to match Flutter model expectations
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    // Omit password hash so sensitive credentials are never exposed via API responses
    delete ret.passwordHash;
    return ret;
  },
});

module.exports = mongoose.model('User', userSchema);
