// ignore_for_file: unused_import, use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';

class EditBookScreen extends StatefulWidget {
  final String token;
  final String bookId;

  const EditBookScreen({Key? key, required this.token, required this.bookId})
    : super(key: key);

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bookService = BookService();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _publishYearController = TextEditingController();
  final _publisherController = TextEditingController();
  final _pagesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coverImageController = TextEditingController();

  String _selectedLanguage = 'Turkish';
  String _selectedGenre = 'Fiction';
  bool _available = true;
  bool _isLoading = true;
  bool _dataLoaded = false;

  // Renk değişkenleri
  final Color _primaryColor = const Color(0xFF6D4C41); // Ana kahverengi
  final Color _accentColor = const Color(0xFFD7CCC8); // Açık kahverengi
  final Color _backgroundColor = const Color(0xFFF5F5F5); // Arka plan rengi

  // Dil ve tür seçenekleri
  final List<String> _languages = [
    'Turkish',
    'English',
    'French',
    'German',
    'Spanish',
  ];

  final List<String> _genres = [
    'Classic',
    'Educational',
    'Turkish Literature',
    'Fiction',
    'Science Fiction',
    'Mystery',
    'Romance',
    'Biography',
    'Magical Realism',
  ];

  @override
  void initState() {
    super.initState();
    _loadBookDetails();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _publishYearController.dispose();
    _publisherController.dispose();
    _pagesController.dispose();
    _descriptionController.dispose();
    _coverImageController.dispose();
    super.dispose();
  }

  Future<void> _loadBookDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final book = await _bookService.getBookById(widget.token, widget.bookId);

      // Form alanlarını kitap bilgileriyle doldur
      _titleController.text = book.title;
      _authorController.text = book.author;
      _isbnController.text = book.isbn;
      _publishYearController.text = book.publishYear.toString();
      _publisherController.text = book.publisher;
      _pagesController.text = book.pages.toString();
      _descriptionController.text = book.description;
      _coverImageController.text = book.coverImage;

      // API'den gelen dil ve tür bilgilerini kontrol et
      String language = book.language.isNotEmpty ? book.language : 'Turkish';
      String genre = book.genre.isNotEmpty ? book.genre : 'Fiction';

      // Eğer API'den gelen değerler listelerimizde yoksa, listelere ekle
      if (!_languages.contains(language)) {
        _languages.add(language);
      }
      if (!_genres.contains(genre)) {
        _genres.add(genre);
      }

      setState(() {
        _selectedLanguage = language;
        _selectedGenre = genre;
        _available = book.available;
        _dataLoaded = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kitap bilgileri yüklenirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateBook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _bookService.updateBookFull(
        token: widget.token,
        id: widget.bookId,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        isbn: _isbnController.text.trim(),
        publishYear: int.tryParse(_publishYearController.text.trim()) ?? 0,
        publisher: _publisherController.text.trim(),
        pages: int.tryParse(_pagesController.text.trim()) ?? 0,
        language: _selectedLanguage,
        genre: _selectedGenre,
        description: _descriptionController.text.trim(),
        coverImage: _coverImageController.text.trim(),
        available: _available,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kitap başarıyla güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // true olarak dön ki liste yenilensin
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Güncelleme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    String? helperText,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          labelStyle: TextStyle(color: _primaryColor),
          prefixIcon: icon != null ? Icon(icon, color: _primaryColor) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _accentColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _accentColor),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return '$label alanı zorunludur';
              }
              return null;
            },
      ),
    );
  }

  Widget buildDropdown(
    String label,
    List<String> items,
    String value,
    void Function(String?) onChanged, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _primaryColor),
          prefixIcon: icon != null ? Icon(icon, color: _primaryColor) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _accentColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _accentColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 5,
          ),
        ),
        items:
            items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: onChanged,
        validator:
            (value) => value == null || value.isEmpty ? '$label gerekli' : null,
        icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
        isExpanded: true,
        dropdownColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && !_dataLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kitap Güncelle'),
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          color: _backgroundColor,
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF6D4C41)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Kitap Güncelle'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _updateBook,
            tooltip: 'Kitabı Güncelle',
          ),
        ],
      ),
      body: Container(
        color: _backgroundColor,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kapak Resmi Önizleme
                  if (_coverImageController.text.isNotEmpty)
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _coverImageController.text,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    height: 180,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: _accentColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: _primaryColor,
                                    ),
                                  ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.refresh, color: _primaryColor),
                                onPressed: () {
                                  setState(() {
                                    // Görüntüyü yenileme
                                  });
                                },
                                tooltip: 'Görüntüyü Yenile',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Kitap Bilgileri Kartı
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Temel Bilgiler',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          buildTextField(
                            _titleController,
                            'Kitap Adı',
                            icon: Icons.book,
                            maxLength: 100,
                          ),
                          buildTextField(
                            _authorController,
                            'Yazar',
                            icon: Icons.person,
                            maxLength: 80,
                          ),
                          buildTextField(
                            _isbnController,
                            'ISBN',
                            icon: Icons.qr_code,
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9\-X]'),
                              ), // Sadece rakam, tire ve X karakterine izin ver
                            ],
                            maxLength: 17, // ISBN-13 için (13 rakam + 4 tire)
                            helperText: 'Örnek: 978-3-16-148410-0',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'ISBN alanı zorunludur';
                              }

                              // ISBN temizleme (tire ve boşlukları kaldır)
                              String cleanIsbn = value.replaceAll(
                                RegExp(r'[\s\-]'),
                                '',
                              );

                              // ISBN-10 veya ISBN-13 kontrolü
                              if (cleanIsbn.length != 10 &&
                                  cleanIsbn.length != 13) {
                                return 'ISBN numarası 10 veya 13 karakter olmalıdır';
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Yayın Bilgileri Kartı
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Yayın Bilgileri',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          buildTextField(
                            _publisherController,
                            'Yayınevi',
                            icon: Icons.business,
                            maxLength: 80,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: buildTextField(
                                  _publishYearController,
                                  'Yayın Yılı',
                                  icon: Icons.calendar_today,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  maxLength: 4,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Yayın yılı zorunludur';
                                    }

                                    int? year = int.tryParse(value);
                                    if (year == null) {
                                      return 'Geçerli bir yıl girin';
                                    }

                                    if (year < 1000 ||
                                        year > DateTime.now().year) {
                                      return 'Geçerli bir yıl girin';
                                    }

                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: buildTextField(
                                  _pagesController,
                                  'Sayfa Sayısı',
                                  icon: Icons.insert_drive_file,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  maxLength: 5,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Sayfa sayısı zorunludur';
                                    }

                                    int? pages = int.tryParse(value);
                                    if (pages == null || pages <= 0) {
                                      return 'Geçerli bir sayı girin';
                                    }

                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Kategori Bilgileri Kartı
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Kategori Bilgileri',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          buildDropdown('Dil', _languages, _selectedLanguage, (
                            newValue,
                          ) {
                            if (newValue != null) {
                              setState(() {
                                _selectedLanguage = newValue;
                              });
                            }
                          }, icon: Icons.language),
                          buildDropdown('Tür', _genres, _selectedGenre, (
                            newValue,
                          ) {
                            if (newValue != null) {
                              setState(() {
                                _selectedGenre = newValue;
                              });
                            }
                          }, icon: Icons.category),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // İçerik Bilgileri Kartı
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              'İçerik Bilgileri',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          buildTextField(
                            _descriptionController,
                            'Açıklama',
                            maxLines: 3,
                            icon: Icons.description,
                            maxLength: 500,
                          ),
                          buildTextField(
                            _coverImageController,
                            'Kapak URL',
                            icon: Icons.image,
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null; // URL opsiyonel olabilir
                              }
                              if (!value.startsWith('http://') &&
                                  !value.startsWith('https://')) {
                                return 'Geçerli bir URL girin (http:// veya https://)';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Durum Kartı
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Durum Bilgisi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SwitchListTile(
                            title: const Text(
                              'Ödünç verilebilir mi?',
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              _available
                                  ? 'Kitap ödünç alınmaya uygun'
                                  : 'Kitap ödünç alınamaz',
                              style: TextStyle(
                                color: _available ? Colors.green : Colors.red,
                                fontSize: 14,
                              ),
                            ),
                            value: _available,
                            activeColor: _primaryColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            onChanged:
                                (value) => setState(() => _available = value),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Güncelleme Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.update),
                      label:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'GÜNCELLE',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _isLoading ? null : _updateBook,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
