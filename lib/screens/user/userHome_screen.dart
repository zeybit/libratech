import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/book_service.dart';
import '../../services/borrow_service.dart';
import '../../widgets/borrowed_books_screen.dart';
import '../../widgets/user_drawer.dart';
import '../book/book_detail.dart';
import '../login/login_screen.dart';

class UserHomeScreen extends StatefulWidget {
  final String token;
  const UserHomeScreen({super.key, required this.token});

  @override
  State<UserHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<UserHomeScreen> {
  final BookService _bookService = BookService();
  final BorrowService _borrowService = BorrowService();
  late Future<List<Map<String, dynamic>>> _bookListFuture;
  String? _userId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bookListFuture = _bookService.getBooks(widget.token);
    _getUserId();
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('role');

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _bookListFuture = _bookService.getBooks(widget.token);
      }
    });
  }

  void _borrowBook(String bookId) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu özellik henüz hazır değil.')),
      );
      return;
    }

    try {
      final borrowResult = await _borrowService.borrowBook(
        widget.token,
        bookId,
        _userId!,
      );

      if (borrowResult['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kitap başarıyla ödünç alındı')),
        );
        setState(() {
          _bookListFuture = _bookService.getBooks(widget.token);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(borrowResult['message'] ?? 'Kitap ödünç alınamadı')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  void _viewBorrowedBooks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BorrowedBooksScreen(token: widget.token),
      ),
    ).then((_) {
      setState(() {
        _bookListFuture = _bookService.getBooks(widget.token);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6D4C41), // Koyu kahverengi
        title: const Text("Kitaplar", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.book, color: Colors.white),
            onPressed: _viewBorrowedBooks,
            tooltip: 'Ödünç Aldıklarım',
          ),
        ],
      ),
      drawer: UserDrawer(token: widget.token, onLogout: _logout),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFD7CCC8), // Açık kahverengi
                labelText: 'Kitap Ara',
                hintText: 'Kitap adı veya yazar...',
                prefixIcon: Icon(Icons.search, color: Colors.brown),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: Colors.brown),
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
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
                final filteredBooks = _searchQuery.isEmpty
                    ? books
                    : books.where((book) {
                  final title = book['title']?.toString().toLowerCase() ?? '';
                  final author = book['author']?.toString().toLowerCase() ?? '';
                  return title.contains(_searchQuery) || author.contains(_searchQuery);
                }).toList();

                if (filteredBooks.isEmpty) {
                  return Center(child: Text("Arama sonucuna uygun kitap bulunamadı."));
                }

                return ListView.builder(
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    final bool isAvailable = book['available'] == true;

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      color: Color(0xFFF5E1DC), // Açık bej
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5.0,
                      child: ListTile(
                        title: Text(book['title'] ?? 'Başlık yok', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(book['author'] ?? 'Yazar yok'),
                            Text(
                              isAvailable ? 'Durum: Mevcut' : 'Durum: Ödünç Alınmış',
                              style: TextStyle(
                                color: isAvailable ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: isAvailable
                            ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6D4C41),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () => _borrowBook(book['_id'] ?? book['id']),
                          child: const Text('Ödünç Al',
                          style: TextStyle(color: Colors.white),),
                        )
                            : const Icon(Icons.book_outlined, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailScreen(
                                bookId: book['_id'] ?? book['id'],
                                token: widget.token,
                              ),
                            ),
                          );
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
    );
  }
}
