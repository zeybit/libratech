const express = require('express');
const router = express.Router();
const bookController = require('../controllers/bookController');
const admin = require('../middleware/adminMiddleware');
const protect = require('../middleware/authMiddleware');

// Public routes
router.get('/', bookController.getBooks);
router.get('/:id', bookController.getBookById);

// Admin routes
router.post('/', protect, admin, bookController.addBook);
router.put('/:id', protect, admin, bookController.updateBook);
router.delete('/:id', protect, admin, bookController.deleteBook);

module.exports = router;