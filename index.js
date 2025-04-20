require('dotenv').config({path : './backend/.env'});
const mongoose = require('mongoose');


mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('✅ Veritabanına bağlanıldı');
  })
  .catch((err) => {
    console.error('❌ Veritabanı bağlantı hatası:', err);
  });
 
