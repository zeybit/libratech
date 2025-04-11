# libratech
# Libratech Backend

Bu proje, bir kütüphane yönetim sistemi için backend API'sini sağlar. Aşağıdaki adımları izleyerek projeyi çalıştırabilirsiniz.

## Özellikler

- Kullanıcı yönetimi (kayıt, giriş, yetkilendirme)
- Kitap yönetimi (ekleme, silme, güncelleme)
- Kütüphane işlemleri (ödünç alma, iade)
- JWT tabanlı kimlik doğrulama

## Gereksinimler

- **Node.js** (v14 veya üstü)
- **npm** veya **yarn**
- **MongoDB** (lokal veya bulut tabanlı)

## Kurulum

1. **Projeyi klonlayın**:

   ```bash
   git clone https://github.com/kullaniciadi/libratech-backend.git
   cd libratech-backend

2.Bağımlılıkları yükleyin:
npm install   

3.Çevresel değişkenleri yapılandırın:

Proje dizininde bir .env dosyası oluşturun ve aşağıdaki bilgileri ekleyin:
   MONGO_URI=mongodb://localhost:27017/Library



- `MONGO_URI`: MongoDB bağlantı URI'si.
- `PORT`: Sunucunun çalışacağı port.
- `JWT_SECRET`: JWT token oluşturmak için kullanılan gizli anahtar.

## Çalıştırma

1. **Geliştirme modunda çalıştırmak için**:

   ```bash
   npm run dev

2.Üretim modunda çalıştırmak için:
npm start
Başarılı bir şekilde çalıştığında, aşağıdaki mesajı göreceksiniz:

Sunucu 5000 portunda çalışıyor

API Endpoint'leri
Kullanıcılar
-POST /api/users/register - Yeni bir kullanıcı kaydı oluşturur.
-POST /api/users/login - Kullanıcı girişi yapar.
Kitaplar
-GET /api/books - Tüm kitapları listeler.
-POST /api/books - Yeni bir kitap ekler.
-PUT /api/books/:id - Mevcut bir kitabı günceller.
-DELETE /api/books/:id - Bir kitabı siler.
Ödünç Alma
-POST /api/borrow - Kitap ödünç alır.
-POST /api/return - Kitap iade eder.
