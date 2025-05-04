import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/book_model.dart';
import '../../services/book_service.dart';

import '../login/login_screen.dart';
import 'add_book_screen.dart';
import 'admin_drawer.dart';
import 'edit_book_screen.dart';

class BookManagementScreen extends StatefulWidget {
  final String token;
  const BookManagementScreen({super.key, required this.token});

  @override
  State<BookManagementScreen> createState() => _BookManagementScreenState();
}

class _BookManagementScreenState extends State<BookManagementScreen> {
  final BookService _bookService = BookService();
  late Future<List<Book>> _bookListFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _bookListFuture = _bookService.getBooks(widget.token);
  }

  // Çıkış fonksiyonu
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Arama işlemi
  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  // Kitap silme işlemi
  void _deleteBook(String bookId) async {
    try {
      if (bookId.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Kitap ID'si boş olamaz")));
        return;
      }

      // Debug the token value
      print("Token being used for deletion: ${widget.token}");

      if (widget.token.isEmpty) {
        // If token is empty, try to get it from shared preferences
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token') ?? '';

        if (token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Token bulunamadı, lütfen tekrar giriş yapın"),
            ),
          );
          return;
        }

        await _bookService.deleteBook(token, bookId);
      } else {
        await _bookService.deleteBook(widget.token, bookId);
      }

      setState(() {
        _bookListFuture = _bookService.getBooks(widget.token);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Kitap başarıyla silindi")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Silme işlemi başarısız: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D4C41),
        title: const Text("Kitaplar", style: TextStyle(color: Colors.white)),
      ),
      drawer: AdminDrawer(token: widget.token, onLogout: _logout),

      // GÖVDE
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFD7CCC8),
                hintText: 'Kitap adı veya yazar...',
                prefixIcon: const Icon(Icons.search, color: Colors.brown),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.brown),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: _bookListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Hata: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Hiç kitap yok."));
                }

                final books = snapshot.data!;
                final filteredBooks =
                    books.where((book) {
                      final title = book.title.toLowerCase();
                      final author = book.author.toLowerCase();
                      return title.contains(_searchQuery) ||
                          author.contains(_searchQuery);
                    }).toList();

                if (filteredBooks.isEmpty) {
                  return const Center(
                    child: Text("Arama sonucuna uygun kitap bulunamadı."),
                  );
                }

                return ListView.builder(
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    final isAvailable = book.available;

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      color: const Color(0xFFF5E1DC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5.0,
                      child: ListTile(
                        title: Text(
                          book.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(book.author),
                            Text(
                              isAvailable
                                  ? 'Durum: Mevcut'
                                  : 'Durum: Ödünç Alınmış',
                              style: TextStyle(
                                color: isAvailable ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text("Kitabı Sil"),
                                    content: const Text(
                                      "Bu kitabı silmek istediğinize emin misiniz?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                        child: const Text("İptal"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _deleteBook(book.id);
                                        },
                                        child: const Text(
                                          "Sil",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        ),
                        // Kitap kartındaki onTap metodunu güncelleme
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => EditBookScreen(
                                    token: widget.token,
                                    bookId: book.id,
                                  ),
                            ),
                          ).then((updated) {
                            if (updated == true) {
                              setState(() {
                                _bookListFuture = _bookService.getBooks(
                                  widget.token,
                                );
                              });
                            }
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // + Butonu
      floatingActionButton: Tooltip(
        message: 'Kitap Ekle',
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF6D4C41),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddBookScreen(token: widget.token),
              ),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
