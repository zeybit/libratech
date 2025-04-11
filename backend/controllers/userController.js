const User = require('../models/User');
const jwt = require('jsonwebtoken');

// Kullanıcı kaydı
exports.registerUser = async (req, res) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ message: 'Lütfen tüm alanları doldurun.' });
  }

  try {
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ message: 'Bu e-posta ile bir kullanıcı zaten var.' });
    }

    const newUser = new User({ name, email, password });
    await newUser.save();

    res.status(201).json({
      message: 'Kullanıcı başarıyla oluşturuldu.',
      user: { name: newUser.name, email: newUser.email },
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Kullanıcı girişi (JWT üretme)
exports.loginUser = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Lütfen tüm alanları doldurun.' });
  }

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'E-posta adresi veya şifre hatalı.' });
    }

    const isMatch = await user.matchPassword(password);
    if (!isMatch) {
      return res.status(400).json({ message: 'E-posta adresi veya şifre hatalı.' });
    }

    // JWT token oluştur
    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, {
      expiresIn: '30d',
    });

    res.status(200).json({ message: 'Giriş başarılı', token });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
