const mongoose = require('mongoose');

const bookSchema = new mongoose.Schema({
  title: { type: String, required: true },
  author: { type: String, required: true },
  isbn: { type: String, unique: true },
  publishYear: { type: Number },
  publisher: { type: String },
  pages: { type: Number },
  language: { type: String, default: 'Turkish' },
  genre: { type: String },
  description: { type: String },
  coverImage: { type: String },
  available: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Book', bookSchema, 'Books');
