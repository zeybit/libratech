const Borrow = require('../models/Borrow');
const Book = require('../models/Book');

// Kitap ödünç alma
exports.borrowBook = async (req, res) => {
  try {
    const { bookId, dueDate } = req.body;
    const userId = req.user._id; // Kullanıcı kimliği auth middleware'den gelir
    
    // Kitabın varlığını ve müsaitliğini kontrol et
    const book = await Book.findById(bookId);
    if (!book) {
      return res.status(404).json({ message: 'Kitap bulunamadı.' });
    }
    
    if (!book.available) {
      return res.status(400).json({ message: 'Kitap şu anda müsait değil.' });
    }
    
    // Tarihi doğrula
    const dueDateObj = new Date(dueDate);
    if (isNaN(dueDateObj.getTime()) || dueDateObj <= new Date()) {
      return res.status(400).json({ message: 'Geçerli bir iade tarihi belirtmelisiniz.' });
    }
    
    // Ödünç alma kaydı oluştur
    const borrow = new Borrow({
      user: userId,
      book: bookId,
      dueDate: dueDateObj
    });
    
    await borrow.save();
    
    // Kitabın durumunu güncelle
    book.available = false;
    await book.save();
    
    res.status(201).json({
      message: 'Kitap başarıyla ödünç alındı.',
      borrow
    });
    
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message });
  }
};

// Kitap iade etme
exports.returnBook = async (req, res) => {
  try {
    const { borrowId } = req.body;
    
    // Ödünç alma kaydını bul
    const borrow = await Borrow.findById(borrowId);
    if (!borrow) {
      return res.status(404).json({ message: 'Ödünç alma kaydı bulunamadı.' });
    }
    
    // Yetkilendirme kontrolü: sadece ödünç alan kişi veya admin iade edebilir
    if (borrow.user.toString() !== req.user._id.toString() && !req.user.isAdmin) {
      return res.status(403).json({ message: 'Bu işlem için yetkiniz yok.' });
    }
    
    // Zaten iade edilmiş mi kontrol et
    if (borrow.status === 'returned') {
      return res.status(400).json({ message: 'Bu kitap zaten iade edilmiş.' });
    }
    
    // İade tarihini ve durumunu güncelle
    borrow.returnDate = new Date();
    borrow.status = 'returned';
    await borrow.save();
    
    // Kitabın durumunu güncelle
    const book = await Book.findById(borrow.book);
    book.available = true;
    await book.save();
    
    res.status(200).json({
      message: 'Kitap başarıyla iade edildi.',
      borrow
    });
    
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message });
  }
};

// Kullanıcının ödünç aldığı kitapları getir
exports.getUserBorrows = async (req, res) => {
  try {
    const userId = req.user._id;
    
    const borrows = await Borrow.find({ user: userId })
      .populate('book', 'title author coverImage')
      .sort({ borrowDate: -1 });
      
    res.status(200).json(borrows);
    
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message });
  }
};

// Tüm ödünç alma işlemlerini getir (admin için)
exports.getAllBorrows = async (req, res) => {
  try {
    if (!req.user.isAdmin) {
      return res.status(403).json({ message: 'Bu işlem için yetkiniz yok.' });
    }
    
    const borrows = await Borrow.find()
      .populate('user', 'name email')
      .populate('book', 'title author')
      .sort({ borrowDate: -1 });
      
    res.status(200).json(borrows);
    
  } catch (error) {
    res.status(500).json({ message: 'Sunucu hatası', error: error.message });
  }
};