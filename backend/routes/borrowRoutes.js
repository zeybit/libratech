const express = require('express');
const router = express.Router();
const borrowController = require('../controllers/borrowController');
const protect = require('../middleware/authMiddleware');

// All borrow routes require authentication
router.use(protect);

// Book borrowing routes
router.post('/', borrowController.borrowBook);
router.post('/return', borrowController.returnBook);
router.get('/user', borrowController.getUserBorrows);
router.get('/all', borrowController.getAllBorrows);

module.exports = router;