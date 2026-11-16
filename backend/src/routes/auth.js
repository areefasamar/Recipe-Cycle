const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const auth = require('../middleware/auth');

router.post('/register', authController.register);
router.post('/login', authController.login);
// Protect profile endpoint so only authenticated users with valid JWT can access it
router.get('/me', auth, authController.me);

module.exports = router;
