const express = require('express');
const router = express.Router();
const { registerUser, loginUser,getUsers } = require('../controllers/userController');
const protect = require('../middleware/authMiddleware');
const admin = require('../middleware/adminMiddleware');

router.post('/register', registerUser);
router.post('/login', loginUser);

router.get('/',protect, admin, getUsers);
module.exports = router;
