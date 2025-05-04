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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kitap bilgileri yüklenirken hata: $e')),
      );
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
        const SnackBar(content: Text('Kitap başarıyla güncellendi')),
      );
      Navigator.pop(context, true); // true olarak dön ki liste yenilensin
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Güncelleme hatası: $e')));
    }
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.brown.shade700) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.brown.shade700, width: 2),
          ),
          filled: true,
          fillColor: Colors.brown.shade50,
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
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.brown.shade700) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.brown.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.brown.shade700, width: 2),
          ),
          filled: true,
          fillColor: Colors.brown.shade50,
        ),
        items:
            items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: onChanged,
        validator:
            (value) => value == null || value.isEmpty ? '$label gerekli' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kahveRenk = Colors.brown.shade700;

    if (_isLoading && !_dataLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kitap Güncelle'),
          backgroundColor: kahveRenk,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Kitap Güncelle'),
        backgroundColor: kahveRenk,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.brown[100],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık ve yazar
                buildTextField(_titleController, 'Kitap Adı', icon: Icons.book),
                buildTextField(_authorController, 'Yazar', icon: Icons.person),

                // ISBN ve Yayın Yılı
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: buildTextField(
                        _isbnController,
                        'ISBN',
                        icon: Icons.qr_code,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ISBN gerekli';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: buildTextField(
                        _publishYearController,
                        'Yayın Yılı',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Yıl gerekli';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Geçerli bir yıl girin';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                // Yayınevi ve Sayfa Sayısı
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: buildTextField(
                        _publisherController,
                        'Yayınevi',
                        icon: Icons.business,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: buildTextField(
                        _pagesController,
                        'Sayfa Sayısı',
                        icon: Icons.insert_drive_file,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Sayfa sayısı gerekli';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Geçerli bir sayı girin';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                // Dil ve Tür
                buildDropdown('Dil', _languages, _selectedLanguage, (newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                  });
                }, icon: Icons.language),

                buildDropdown('Tür', _genres, _selectedGenre, (newValue) {
                  setState(() {
                    _selectedGenre = newValue!;
                  });
                }, icon: Icons.category),

                // Açıklama ve Kapak URL
                buildTextField(
                  _descriptionController,
                  'Açıklama',
                  maxLines: 3,
                  icon: Icons.description,
                ),

                buildTextField(
                  _coverImageController,
                  'Kapak URL',
                  icon: Icons.image,
                ),

                // Ödünç verilebilir mi?
                SwitchListTile(
                  title: Text(
                    'Ödünç verilebilir mi?',
                    style: TextStyle(color: kahveRenk),
                  ),
                  activeColor: kahveRenk,
                  value: _available,
                  onChanged: (value) => setState(() => _available = value),
                ),

                const SizedBox(height: 20),

                // Güncelleme butonu
                SizedBox(
                  width: double.infinity,
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
                            : const Text('Güncelle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kahveRenk,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _updateBook,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
