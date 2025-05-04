const User = require('../models/User');
const jwt = require('jsonwebtoken');
const asyncHandler = require('express-async-handler');  // Change this line

// Kullanıcı kaydı
exports.registerUser = asyncHandler(async (req, res) => {  // Wrap with asyncHandler
  const { name, email, password, isAdmin } = req.body;  // Changed role to isAdmin to match schema

  if (!name || !email || !password) {
    return res.status(400).json({ message: 'Lütfen tüm alanları doldurun.' });
  }

  const userExists = await User.findOne({ email });
  if (userExists) {
    return res.status(400).json({ message: 'Bu e-posta ile bir kullanıcı zaten var.' });
  }

  const newUser = new User({ 
    name, 
    email, 
    password,
    isAdmin: isAdmin === true  // Set isAdmin based on request
  });
  
  await newUser.save();

  res.status(201).json({
    message: 'Kullanıcı başarıyla oluşturuldu.',
    user: { name: newUser.name, email: newUser.email, isAdmin: newUser.isAdmin }
  });
});

// Kullanıcı girişi (JWT üretme)
exports.loginUser = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email });

  if (user && (await user.matchPassword(password))) {
    res.json({
      message: "Giriş başarılı",
      token: generateToken(user._id, user.isAdmin),
      user: {
        _id: user._id,
        name: user.name,
        email: user.email,
        isAdmin: user.isAdmin
      }
    });
  } else {
    res.status(401);
    throw new Error('Geçersiz email veya şifre');
  }
});

exports.getUsers = asyncHandler(async (req, res) => {
  const users = await User.find({}).select('-password');
  
  res.status(200).json(users);
});

// Token oluşturma fonksiyonu
const generateToken = (id, isAdmin) => {
  return jwt.sign(
    { 
      id,
      isAdmin
    }, 
    process.env.JWT_SECRET, 
    { expiresIn: '30d' }
  );
};