const jwt = require('jsonwebtoken');

const auth = (req, res, next) => {
  const authHeader = req.headers.authorization;

  // Enforce standard Bearer token scheme in the Authorization header
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Authorization token required' });
  }

  // Extract raw JWT token string following 'Bearer '
  const token = authHeader.split(' ')[1];

  try {
    // Verify token integrity and expiration using secret key
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    // Attach decoded user identifier to the request for downstream handlers
    req.userId = decoded.userId;
    next();
  } catch (err) {
    // Treat invalid signatures and expired tokens equally as unauthorized
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
};

module.exports = auth;
