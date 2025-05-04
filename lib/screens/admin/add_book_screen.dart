import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/book_service.dart';

class AddBookScreen extends StatefulWidget {
  final String token;
  const AddBookScreen({super.key, required this.token});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _publishYearController = TextEditingController();
  final _publisherController = TextEditingController();
  final _pagesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coverImageController = TextEditingController();
  bool _available = true;
  bool _isLoading = false;

  // Available languages based on your database
  final List<String> _languages = [
    'Turkish',
    'English',
    'French',
    'German',
    'Spanish',
  ];
  String _selectedLanguage = 'Turkish'; // Default value

  // Available genres based on your database
  final List<String> _genres = [
    'Classic',
    'Educational',
    'Turkish Literature',
    'Fiction',
    'Science Fiction',
    'Mystery',
    'Romance',
    'Biography',
  ];
  String _selectedGenre = 'Fiction'; // Default value

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      print("Using token for book creation: ${widget.token}");

      String token = widget.token;

      // If token is empty, try to get it from SharedPreferences
      if (token.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('token') ?? '';
        print(
          "Retrieved token from SharedPreferences: ${token.isNotEmpty ? '${token.substring(0, 20)}...' : 'Empty'}",
        );

        if (token.isEmpty) {
          throw Exception('Token is empty, please log in again');
        }
      }

      await BookService().addBook(
        token: token,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        isbn: _isbnController.text.trim(),
        publishYear: int.parse(_publishYearController.text.trim()),
        publisher: _publisherController.text.trim(),
        pages: int.parse(_pagesController.text.trim()),
        language: _selectedLanguage,
        genre: _selectedGenre,
        description: _descriptionController.text.trim(),
        coverImage: _coverImageController.text.trim(),
        available: _available,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kitap başarıyla eklendi')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
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

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.brown[700]) : null,
          filled: true,
          fillColor: Colors.brown[50],
          labelStyle: TextStyle(color: Colors.brown[800]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.brown.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.brown.shade700, width: 2),
          ),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator:
            (value) => value == null || value.isEmpty ? '$label gerekli' : null,
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.brown[700]) : null,
          filled: true,
          fillColor: Colors.brown[50],
          labelStyle: TextStyle(color: Colors.brown[800]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.brown.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.brown.shade700, width: 2),
          ),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Kitap Ekle'),
        backgroundColor: kahveRenk,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.brown[100],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Card(
              color: Colors.brown[50],
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildTextField(
                      _titleController,
                      'Kitap Adı',
                      icon: Icons.book,
                    ),
                    buildTextField(
                      _authorController,
                      'Yazar',
                      icon: Icons.person,
                    ),
                    buildTextField(
                      _isbnController,
                      'ISBN',
                      icon: Icons.numbers,
                    ),
                    buildTextField(
                      _publishYearController,
                      'Yayın Yılı',
                      isNumber: true,
                      icon: Icons.date_range,
                    ),
                    buildTextField(
                      _publisherController,
                      'Yayınevi',
                      icon: Icons.print,
                    ),
                    buildTextField(
                      _pagesController,
                      'Sayfa Sayısı',
                      isNumber: true,
                      icon: Icons.menu_book,
                    ),

                    // Replace text fields with dropdowns for language and genre
                    buildDropdown('Dil', _languages, _selectedLanguage, (
                      newValue,
                    ) {
                      setState(() {
                        _selectedLanguage = newValue!;
                      });
                    }, icon: Icons.language),

                    buildDropdown('Tür', _genres, _selectedGenre, (newValue) {
                      setState(() {
                        _selectedGenre = newValue!;
                      });
                    }, icon: Icons.category),

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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Kaydet'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kahveRenk,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _submitForm,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
