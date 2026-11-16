const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Helper to issue signed JWTs for authenticated sessions
const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
};

// Simple email regex format check
const isValidEmail = (email) => {
  return typeof email === 'string' && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
};

// POST /api/auth/register
const register = async (req, res) => {
  const { name, email, password } = req.body;

  if (!name || typeof name !== 'string' || !name.trim()) {
    return res.status(400).json({ message: 'Name is required' });
  }

  if (!isValidEmail(email)) {
    return res.status(400).json({ message: 'A valid email is required' });
  }

  // Require minimum length to prevent weak, easily guessable passwords
  if (!password || typeof password !== 'string' || password.length < 8) {
    return res
      .status(400)
      .json({ message: 'Password must be at least 8 characters long' });
  }

  try {
    const normalizedEmail = email.trim().toLowerCase();

    // Prevent duplicate accounts by ensuring email uniqueness before creating
    const existingUser = await User.findOne({ email: normalizedEmail });
    if (existingUser) {
      return res.status(409).json({ message: 'Email already exists' });
    }

    // Salt and hash password with cost factor 10 to resist brute-force attacks
    const passwordHash = await bcrypt.hash(password, 10);

    const user = new User({
      name: name.trim(),
      email: normalizedEmail,
      passwordHash,
    });
    await user.save();

    const token = generateToken(user._id.toString());
    res.status(201).json({ token, user });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// POST /api/auth/login
const login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    // Provide uniform error message to prevent user enumeration attacks
    return res.status(401).json({ message: 'Invalid email or password' });
  }

  try {
    const normalizedEmail = String(email).trim().toLowerCase();
    const user = await User.findOne({ email: normalizedEmail });

    // Use identical error message for missing user as invalid password to avoid email probing
    if (!user) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    // Compare input against stored bcrypt hash using constant-time comparison
    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const token = generateToken(user._id.toString());
    res.status(200).json({ token, user });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET /api/auth/me
const me = async (req, res) => {
  try {
    // Retrieve user record using the verified user ID from the auth token
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.status(200).json({ user });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = {
  register,
  login,
  me,
};
