const asyncHandler = require('express-async-handler');

const admin = asyncHandler(async (req, res, next) => {
  if (req.user && req.user.isAdmin) {
    next();
  } else {
    res.status(401);
    throw new Error('Yetkilendirme başarısız, admin değilsiniz');
  }
});

module.exports = admin;  // Export directly, not as an object