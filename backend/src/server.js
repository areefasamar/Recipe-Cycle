// Load environment variables from .env before anything else
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');

const app = express();
const PORT = process.env.PORT || 3000;

// Allow Flutter Web (running on a different port) to call this API
app.use(cors());
app.use(express.json());

// Connect to MongoDB Atlas; exit early if it fails so we know immediately
connectDB();

// Health check – useful for confirming the server is up before running the app
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
