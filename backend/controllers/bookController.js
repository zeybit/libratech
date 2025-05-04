const Book = require('../models/Book');

// Kitap ekle
exports.addBook = async (req, res) => {
  try {
    const newBook = new Book(req.body);
    const savedBook = await newBook.save();
    res.status(201).json(savedBook);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


// Tüm kitapları getir
exports.getBooks = async (req, res) => {
  try {
    const books = await Book.find();
    res.status(200).json(books);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
// ...existing code...

// Get book by ID
exports.getBookById = async (req, res) => {
  try {
    const id = req.params.id;
    console.log('Requested book ID:', id);
    
    if (!id.match(/^[0-9a-fA-F]{24}$/)) {
      return res.status(400).json({ message: 'Invalid book ID format' });
    }
    
    const book = await Book.findById(id);
    
    if (!book) {
      console.log('Book not found in database');
      return res.status(404).json({ message: 'Book not found' });
    }
    
    console.log('Book found:', book.title);
    res.status(200).json(book);
  } catch (error) {
    console.error('Error fetching book details:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// ...existing code...

// Kitap güncelle
exports.updateBook = async (req, res) => {
  try {
    const updated = await Book.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
    });
    res.status(200).json(updated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Kitap sil
exports.deleteBook = async (req, res) => {
  try {
    await Book.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: 'Book deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
