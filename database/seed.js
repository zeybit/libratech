const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const User = require("./Models/user");
const Book = require("./Models/book");
const Borrow = require("./Models/borrow");
// MongoDB bağlantı
mongoose.connect("mongodb+srv://edagl0321:E8237lurn29@cluster0.sfedg5w.mongodb.net/Libratech?authSource=admin&retryWrites=true&w=majority&appName=Cluster0")
  .then(async () => {
    console.log("Veritabanına bağlandı!");

    // 1. Kullanıcılar
    const usersData = [
      /*
      { name: "Ayşe", email: "ayse@example.com", sifre: "123456" },
      { name: "Mehmet", email: "mehmet@example.com", sifre: "password123" },
      { name: "Bora", email: "bora@example.com", sifre: "bora123"},
      { name: "Azra", email: "azra@example.com", sifre: "azra45"},
      { name: "Barış", email: "barış@example.com", sifre: "barış56"},
      { name: "Beren", email: "beren@example.com", sifre: "beren87"},
      { name: "Birce", email: "birce@example.com", sifre: "birce64"},
      { name: "Rana", email: "rana@example.com", sifre: "rana34"},
      { name: "Selin", email: "selin@example.com", sifre: "selin76"},
      { name: "Çağrı", email: "çağrı@example.com", sifre: "çağrı90"},
      { name: "Kerem", email: "kerem@example.com", sifre: "kerem23"},
      { name: "Derin", email: "derin@example.com", sifre: "derin58"}*/
      /*{name: "Zerrin", email: "zerrin@example.com", sifre: "zerrin18"},
      {name: "Ali", email: "ali@example.com", sifre: "ali78"},
      {name: "Doğuş", email: "doğuş@example.com", sifre: "doğuş10"},
      {name: "Esra", email: "esra@example.com", sifre: "esra04"},
      {name: "Gaye", email: "gaye@example.com", sifre: "gaye06"}
      {name: "Nil", email: "nil@example.com", sifre: "nil61"}*/

      {name: "Ada", email: "ada@example.com", sifre: "ada376"},
      {name: "Aren", email: "arem@example.com", sifre: "aren473"},
      {name: "Baran", email: "baran@example.com", sifre: "baran384"},
      {name: "Cenk", email: "cenk@example.com", sifre: "cenk098"},
      {name: "Doğa", email: "doğa@example.com", sifre: "doğa423"},
      {name: "Faruk", email: "faruk@example.com", sifre: "faruk8298"},
      {name: "Hakan", email: "hakan@example.com", sifre: "hakan722"},
      {name: "Hayri", email: "hayri@example.com", sifre: "hayri567"},
      {name: "Kemal", email: "kemal@example.com", sifre: "kemal278"},
      {name: "Orhan", email: "orhan@example.com", sifre: "orhan750"},
      {name: "Selim", email: "selim@example.com", sifre: "selim102"},
      {name: "Veysel", email: "veysel@example.com", sifre: "veysel032"},
      {name: "Yaren", email: "yaren@example.com", sifre: "yaren560"},

    ];

    const createdUsers = [];

    for (const userData of usersData) {
      const hashedPassword = await bcrypt.hash(userData.sifre, 10);
      const user = new User({ ...userData, sifre: hashedPassword });
      await user.save();
      createdUsers.push(user);
    }

    // 2. Kitaplar
    const booksData = [
      /*
      { title: "Kürk Mantolu Madonna", author: "Sabahattin Ali", genre: "Roman", available: true },
      { title: "1984", author: "George Orwell", genre: "Dystopian", available: true },
      { title: "Suç ve Ceza", author: "Dostoyevski", genre: "Psikolojik Gerilim", available: true },
      { title: 'Pride and Prejudice', author: 'Jane Austen', genre: 'Romance', available: false },
      { title: 'To Kill a Mockingbird', author: 'Harper Lee', genre: 'Fiction', available: true },
      { title: 'The Catcher in the Rye', author: 'J.D. Salinger', genre: 'Fiction', available: false },
      { title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Fiction', available: true },
      { title: 'The Lord of the Rings', author: 'J.R.R. Tolkien', genre: 'Fantasy', available: true },
      { title: 'Brave New World', author: 'Aldous Huxley', genre: 'Science Fiction', available: true },
      { title: 'The Alchemist', author: 'Paulo Coelho', genre: 'Adventure', available: false },
      { title: 'Moby-Dick', author: 'Herman Melville', genre: 'Adventure', available: true },
      { title: 'The Hobbit', author: 'J.R.R. Tolkien', genre: 'Fantasy', available: true }*/
      /*{title: "İnce Memed", author:"Yaşar Kemal", genre:"Roman", available:true},
      {title:"Tutunamayanlar", author:"Oğuz Atay", genre: "Kurgu", available:true},
      {title: "Saatleri Ayarlama Enstitüsü", author: "Ahmet Hamdi Tanpınar", genre: "Edebi Kurgu", available: true},
      {title: "Huzur", author:"Ahmet Hamdi Tanpınar", genre:"Tarihi Kurgu", available: true},
      {title: "Anayurt Oteli", author: "Yusuf Atılgan", genre: "Roman", available:true},
      {title: "Kara Kitap", author: "Orhan Pamuk", genre: "Gizem", available:true},
      {title: "Bereketli Topraklar Üzerinde", author:"Orhan Kemal", genre: "Kurgu", available:true},     
      {title: "Aylak Adam", author: "Yusuf Atılgan", genre:"Psikolojik Kurgu", available:true},	
      {title: "Aşk-ı Memnu", author: "Halit Ziya Uşaklıgil", genre:"Realist-Naturalist", available: true},
      {title: "Benim Adım Kırmızı", author: "Orhan Pamuk", genre:"Tarihi Kurgu", available: true},
      {title: "Puslu Kıtalar Atlası", author:	"İhsan Oktay Anar", genre:"Fantastik", available:true},
      {title: "Sevgili Arsız Ölüm", author:	"Latife Tekin", genre:"Kurgu", available:true},
      {title: "Yaban", author:"Yakup Kadri Karaosmanoğlu", genre:"Anı", available:true},
      {title: "Bir Düğün Gecesi", author:	"Adalet Ağaoğlu", genre:"PostModern", available:true},
      {title: "Tehikeli Oyunlar", author:	"Oğuz Atay", genre: "PostModern", available:true},
      {title: "Ölmeye Yatmak", author:"Adalet Ağaoğlu", genre:"Tarih", available:false},
      {title: "Üç İstanbul", author: "Mithat Cemal Kuntay", genre:"", available:true}*/
      
      {title: "Çalıkuşu", author:"Reşat Nuri Güntekin", genre:"Roman", available:true},
      {title:  "Dokuzuncu Hariciye Koğuşu", author:"Peyami Safa", genre:"Roman", available: true},
      {title: "Devlet Ana", author:"Kemal Tahir", genre:"Roman", available: true},
      {title: "Bir Gün Tek Başına", author:"Vedat Türkali", genre:"Roman", available:true},
      {title:"Hakkari'de Bir Mevsim", author:	"Ferit Edgü", genre:"Roman", available:true},
      {title: "Kuyucaklı Yusuf", author:"Sabahattin Ali", genre:"Roman", available:true},
      {title: "Yenişehir'de Bir Öğle Vakti", author:"Sevgi Soysal", genre:"Roman", available:true},
      {title:"Mai ve Siyah", author:"	Halit Ziya Uşaklıgil", genre:"Roman", available:true},
      {title: "Kıskanmak", author:"Nahid Sırrı Örik", genre:"", available:true},
      {title: "Cevdet Bey ve Oğulları", author:	"Orhan Pamuk", genre:"Roman", available: true},
      {title:"Eylül", author:	"Mehmet Rauf", genre:"Roman", available:true},
      {title:"Gece", author:"Bilge Karasu", genre:"Roman", available:true},
      { title: "Fahim Bey ve Biz", author: "Abdülhak Şinasi Hisar", genre: "Roman", available: true },
      { title: "47'liler", author: "Füruzan", genre: "Roman", available: true },
      { title: "Gölgesizler", author: "Hasan Ali Toptaş", genre: "Roman", available: true },
      { title: "Demirciler Çarşısı Cinayeti", author: "Yaşar Kemal", genre: "Roman", available: true },
      { title: "Yorgun Savaşçı", author: "Kemal Tahir", genre: "Roman", available: true },
      { title: "Murtaza", author: "Orhan Kemal", genre: "Roman", available: true },
      { title: "Yer Demir Gök Bakır", author: "Yaşar Kemal", genre: "Roman", available: true },
      { title: "Tuhaf Bir Kadın", author: "Leyla Erbil", genre: "Roman", available: true },
      { title: "Ağır Roman", author: "Metin Kaçan", genre: "Roman", available: true },
      { title: "Ortadirek", author: "Yaşar Kemal", genre: "Roman", available: true },
      { title: "Fırat Suyu Kan Akıyor Baksana", author: "Yaşar Kemal", genre: "Roman", available: true },
      { title: "İçimizdeki Şeytan", author: "Sabahattin Ali", genre: "Roman", available: true },
      { title: "Yalnızız", author: "Peyami Safa", genre: "Roman", available: true },
      { title: "Bin Hüzünlü Haz", author: "Hasan Ali Toptaş", genre: "Roman", available: true },
      { title: "Son Adım", author: "Ayhan Geçgin", genre: "Roman", available: true },
      { title: "Yılanların Öcü", author: "Fakir Baykurt", genre: "Roman", available: true },
      { title: "Her Gece Bodrum", author: "Selim İleri", genre: "Roman", available: true },
      { title: "Sinekli Bakkal", author: "Halide Edip Adıvar", genre: "Roman", available: true },
      { title: "Sultan Hamid Düşerken", author: "Nahid Sırrı Örik", genre: "Roman", available: true },
      { title: "Serenad", author: "Zülfü Livaneli", genre: "Roman", available: true },
      { title: "Tol", author: "Murat Uyurkulak", genre: "Roman", available: true },
      { title: "Ayaşlı ve Kiracıları", author: "Memduh Şevket Esendal", genre: "Roman", available: true },
      { title: "Müşâhedat", author: "Ahmed Midhat", genre: "Roman", available: true },
      { title: "Kinyas ile Kayra", author: "Hakan Günday", genre: "Roman", available: true },
      { title: "Berci Kristin Çöp Masalları", author: "Latife Tekin", genre: "Roman", available: true },
      { title: "Denizin Çağırışı", author: "Kemal Bilbaşar", genre: "Roman", available: true },
      { title: "Kırık Hayatlar", author: "Halid Ziya Uşaklıgil", genre: "Roman", available: true },
      { title: "Kurt Kanunu", author: "Kemal Tahir", genre: "Roman", available: true },
      { title: "Medarı Maişet Motoru", author: "Sait Faik Abasıyanık", genre: "Roman", available: true },
      { title: "Odalarda", author: "Erdal Öz", genre: "Roman", available: true },
      { title: "Yeşil Gece", author: "Reşat Nuri Güntekin", genre: "Roman", available: true },
      { title: "Bir Solgun Adam", author: "Selçuk Baran", genre: "Roman", available: true },
      { title: "Kurtlar Sofrası", author: "Attilâ İlhan", genre: "Roman", available: true },
      { title: "Bir Deliler Evinin Yalan Yanlış Anlatılan Kısa Tarihi", author: "Ayfer Tunç", genre: "Roman", available: true },
      { title: "Buzul Çağının Virüsü", author: "Vüs'at O. Bener", genre: "Roman", available: true },
      { title: "Esir Şehrin İnsanları", author: "Kemal Tahir", genre: "Roman", available: true },
      { title: "Gurbet Kuşları", author: "Orhan Kemal", genre: "Roman", available: true },
      { title: "İstanbul Hatırası", author: "Ahmet Ümit", genre: "Roman", available: true },
      { title: "Mel'un", author: "Selim İleri", genre: "Roman", available: true },
      { title: "Rahmet Yolları Kesti", author: "Kemal Tahir", genre: "Roman", available: true },
      { title: "Bir Kadının Penceresinden", author: "Oktay Rifat", genre: "Roman", available: true },
      { title: "Uzun Sürmüş Bir Günün Akşamı", author: "Bilge Karasu", genre: "Roman", available: true },
      { title: "Heba", author: "Hasan Ali Toptaş", genre: "Roman", available: true },
      { title: "Masumiyet Müzesi", author: "Orhan Pamuk", genre: "Roman", available: true },
      { title: "Yaşamak Güzel Şey Be Kardeşim", author: "Nâzım Hikmet", genre: "Roman", available: true },
      { title: "Çamlıca'daki Eniştemiz", author: "Abdülhak Şinasi Hisar", genre: "Roman", available: true },
      { title: "Çocukluğun Soğuk Geceleri", author: "Tezer Özlü", genre: "Roman", available: true },
      { title: "Kayıp Aranıyor", author: "Sait Faik Abasıyanık", genre: "Roman", available: true },
      { title: "Kiralık Konak", author: "Yakup Kadri Karaosmanoğlu", genre: "Roman", available: true },
      { title: "Eski Hastalık", author: "Reşat Nuri Güntekin", genre: "Roman", available: true },
      { title: "Mutluluk", author: "Zülfü Livaneli", genre: "Roman", available: true },
      { title: "Şimdiki Çocuklar Harika", author: "Aziz Nesin", genre: "Roman", available: true },
      { title: "Boğazkesen", author: "Nedim Gürsel", genre: "Roman", available: true },
      { title: "Karartma Geceleri", author: "Rıfat Ilgaz", genre: "Roman", available: true },
      { title: "Matmazel Noraliya'nın Koltuğu", author: "Peyami Safa", genre: "Roman", available: true },
      { title: "Sahnenin Dışındakiler", author: "Ahmet Hamdi Tanpınar", genre: "Roman", available: true },
      { title: "Yaralısın", author: "Erdal Öz", genre: "Roman", available: true },
      { title: "Yeşilçam Dedikleri Türkiye", author: "Vedat Türkali", genre: "Roman", available: true },
      { title: "Ankara", author: "Yakup Kadri Karaosmanoğlu", genre: "Roman", available: true },
      { title: "Araba Sevdası", author: "Recaizade Mahmud Ekrem", genre: "Roman", available: true },
      { title: "Ateş Gecesi", author: "Reşat Nuri Güntekin", genre: "Roman", available: true },
      { title: "Çılgın Gibi", author: "Suat Derviş", genre: "Roman", available: true },
      { title: "Göçmüş Kediler Bahçesi", author: "Bilge Karasu", genre: "Roman", available: true },
      { title: "Handan", author: "Halide Edib Adıvar", genre: "Roman", available: true },
      { title: "Mahur Beste", author: "Ahmet Hamdi Tanpınar", genre: "Roman", available: true },
      { title: "Şu Çılgın Türkler", author: "Turgut Özakman", genre: "Roman", available: true },
      { title: "Tütün Zamanı", author: "Necati Cumalı", genre: "Roman", available: true },
      { title: "Veda", author: "Ayşe Kulin", genre: "Roman", available: true },
      { title: "Yalan", author: "Tahsin Yücel", genre: "Roman", available: true }
    ];

    const createdBooks = await Book.insertMany(booksData);

    // 3. Ödünç alma işlemleri
    const borrowsData = [
      /*{
        user: createdUsers[0]._id,
        book: createdBooks[1]._id,
        borrowDate: new Date("2025-04-01"),
        returnDate: new Date("2025-04-10")
      },
      {
        user: createdUsers[1]._id,
        book: createdBooks[2]._id,
        borrowDate: new Date("2025-04-12"),
        returnDate: null // henüz teslim edilmemiş
      },
      {
        user: createdUsers[2]._id,
        book: createdBooks[0]._id,
        borrowDate: new Date("2025-04-15"),
        returnDate: null
      },
      {
        user: createdUsers[3]._id,
        book: createdBooks[4]._id,
        borrowDate: new Date("2025-03-25"),
        returnDate: new Date("2025-04-11")
      },
      {
        user: createdUsers[4]._id,
        book: createdBooks[3]._id,
        borrowDate: new Date("2025-03-10"),
        returnDate: new Date("2025-03-21")
      },
      {
        user: createdUsers[5]._id,
        book: createdBooks[3]._id,
        borrowDate: new Date("2025-03-23"),
        returnDate: null
      },
      {
        user: createdUsers[6]._id,
        book: createdBooks[4]._id,
        borrowDate: new Date("2025-04-14"),
        returnDate: null
      },
      {
        user: createdUsers[4]._id,
        book: createdBooks[5]._id,
        borrowDate: new Date("2025-04-18"),
        returnDate: null
      },*/
      {
        user: createdUsers[0]._id,
        book: createdBooks[0]._id,
        borrowDate: new Date("2025-04-16"),
        returnDate: null
      },
      {
        user: createdUsers[2]._id,
        book: createdBooks[3]._id,
        borrowDate: new Date("2025-04-18"),
        returnDate: null
      },
      {
        user: createdUsers[1]._id,
        book: createdBooks[2]._id,
        borrowDate: new Date("2025-04-07"),
        returnDate: new Date("2025-04-19")
      },
      {
        user: createdUsers[5]._id,
        bookk: createdBooks[15]._id,
        borrowDate: new Date("2025-04-19"),
        returnDate: null
      },
      {
        user: createdUsers[6]._id,
        book: createdBooks[20]._id,
        borrowDate: new Date("2025-04-19"),
        returnDate: null
      },
      {
        user: createdUsers[7]._id,
        book: createdBooks[22]._id,
        borrowDate: new Date("2025-04-19"),
        returnDate: null
      },
      {
        user: createdUsers[9]._id,
        book: createdBooks[26]._id,
        borrowDate: new Date("2025-04-19"),
        returnDate: null
      },
      {
        user: createdUsers[11]._id,
        book: createdBooks[23]._id,
        borrowDate: new Date("2025-04-19"),
        returnDate:null
      },
      {
        user: createdUsers[8]._id,
        book: createdBooks[28]._id,
        borrowDate: new Date("2025-04-19"),
        returnDate: null
      },
      {
        user: createdUsers[1]._id,
        book: createdBooks[14]._id,
        borrowDate: new Date("2025-04-19"),
        returnDate: null
      },
      {
        user: createdUsers[0]._id,
        book: createdBooks[19]._id,
        borrowDate: new Date("2025-04-19"),
        returnDate: null
      },
      {
        user: createdUsers[4]._id,
        book: createdBooks[10]._id,
        borrowDate: new Date("2025-04-19"),
        returnDate: null
      },
      {
        user: createdUsers[10]._id,
        book: createdBooks[12]._id,
        borrowDate: new Date("2025-04-19"),
        returnDate: null
      }
    ];
    await Borrow.insertMany(borrowsData);

    console.log("Tüm veriler başarıyla eklendi!");
    mongoose.connection.close();
  })
  .catch(err => {
    console.error("Hata oluştu:", err);
  });
