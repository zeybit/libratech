const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const connectDB = require('./config/db');
const mongoose = require('mongoose');

dotenv.config();
connectDB();

const app = express();

// filepath: c:\Users\zeybit\libratech\backend\server.js
// Replace the current CORS configuration with this simpler version
app.use(cors({
    origin: '*',
    
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']
  }));

app.use(express.json());
app.options('*', cors());
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/books', require('./routes/bookRoutes'));
app.use('/api/borrow', require('./routes/borrowRoutes'));
const PORT = process.env.PORT || 5000;
app.listen(5000, '0.0.0.0', () => {
  console.log('Server running on port 5000');
});
app.get('/', (req, res) => {
  res.send('Sunucu çalışıyor 🎉');
});