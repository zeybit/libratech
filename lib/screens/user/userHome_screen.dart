// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/book_service.dart';
import '../../services/borrow_service.dart';
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
    _bookListFuture = _bookService.getBooks(widget.token) as Future<List<Map<String, dynamic>>>;
    _getUserId();
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  // Kullanıcı çıkışı
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('role');

    // Login ekranına yönlendirme
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Kitap arama
  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      // Eğer sorgu boşsa tüm kitapları göster, değilse filtrelenmiş listeyi göster
      if (_searchQuery.isEmpty) {
        _bookListFuture = _bookService.getBooks(widget.token) as Future<List<Map<String, dynamic>>>;
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
        // Kitap listesini yenile
        setState(() {
          _bookListFuture = _bookService.getBooks(widget.token) as Future<List<Map<String, dynamic>>>;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(borrowResult['message'] ?? 'Kitap ödünç alınamadı'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  // Ödünç alınan kitapları görüntüle
  void _viewBorrowedBooks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _BorrowedBooksScreen(token: widget.token),
      ),
    ).then((_) {
      // Kullanıcı geri döndüğünde kitap listesini yenile
      setState(() {
        _bookListFuture = _bookService.getBooks(widget.token) as Future<List<Map<String, dynamic>>>;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitaplar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: _viewBorrowedBooks,
            tooltip: 'Ödünç Aldıklarım',
          ),
        ],
      ),
      drawer: UserDrawer(token: widget.token, onLogout: _logout),
      body: Column(
        children: [
          // Arama kutusu
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Kitap Ara',
                hintText: 'Kitap adı veya yazar...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                ),
              ),
              onChanged: _performSearch,
            ),
          ),
          // Kitap listesi
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

                // Arama sorgusu varsa, kitapları filtrele
                final filteredBooks =
                    _searchQuery.isEmpty
                        ? books
                        : books.where((book) {
                          final title =
                              book['title']?.toString().toLowerCase() ?? '';
                          final author =
                              book['author']?.toString().toLowerCase() ?? '';
                          return title.contains(_searchQuery) ||
                              author.contains(_searchQuery);
                        }).toList();

                if (filteredBooks.isEmpty) {
                  return Center(
                    child: Text("Arama sonucuna uygun kitap bulunamadı."),
                  );
                }

                return ListView.builder(
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    final bool isAvailable = book['available'] == true;

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(book['title'] ?? 'Başlık yok'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(book['author'] ?? 'Yazar yok'),
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
                        trailing:
                            isAvailable
                                ? ElevatedButton(
                                  onPressed:
                                      () => _borrowBook(
                                        book['_id'] ?? book['id'],
                                      ),
                                  child: const Text('Ödünç Al'),
                                )
                                : const Icon(
                                  Icons.book_outlined,
                                  color: Colors.grey,
                                ),
                        // Kitaba tıklandığında detay sayfasına yönlendirme
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => BookDetailScreen(
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

// Ödünç alınan kitapları gösteren ekran
class _BorrowedBooksScreen extends StatefulWidget {
  final String token;

  const _BorrowedBooksScreen({Key? key, required this.token}) : super(key: key);

  @override
  _BorrowedBooksScreenState createState() => _BorrowedBooksScreenState();
}

class _BorrowedBooksScreenState extends State<_BorrowedBooksScreen> {
  final BorrowService _borrowService = BorrowService();
  late Future<List<Map<String, dynamic>>> _borrowedBooksFuture;

  @override
  void initState() {
    super.initState();
    _borrowedBooksFuture = _borrowService.getBorrowedBooks(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ödünç Aldığım Kitaplar')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _borrowedBooksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Henüz ödünç aldığınız kitap bulunmamaktadır.'),
            );
          }

          final borrowedBooks = snapshot.data!;
          return ListView.builder(
            itemCount: borrowedBooks.length,
            itemBuilder: (context, index) {
              final book = borrowedBooks[index];
              final borrowDate =
                  book['borrowDate'] != null
                      ? DateTime.parse(book['borrowDate'])
                      : null;
              final returnDate =
                  book['returnDate'] != null
                      ? DateTime.parse(book['returnDate'])
                      : null;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    book['bookTitle'] ?? book['book']?['title'] ?? 'Başlık yok',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book['bookAuthor'] ??
                            book['book']?['author'] ??
                            'Yazar yok',
                      ),
                      if (borrowDate != null)
                        Text('Alınma Tarihi: ${_formatDate(borrowDate)}'),
                      if (returnDate != null)
                        Text('İade Tarihi: ${_formatDate(returnDate)}'),
                      if (returnDate == null)
                        Text(
                          'Durumu: Henüz İade Edilmedi',
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                  trailing:
                      returnDate == null
                          ? ElevatedButton(
                            onPressed:
                                () => _returnBook(book['_id'] ?? book['id']),
                            child: const Text('İade Et'),
                          )
                          : Icon(Icons.check_circle, color: Colors.green),
                  // Kitaba tıklandığında detayları görüntüle
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BookDetailScreen(
                              bookId:
                                  book['bookId'] ?? book['book']?['_id'] ?? '',
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _returnBook(String borrowId) async {
    try {
      final success = await _borrowService.returnBook(widget.token, borrowId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kitap başarıyla iade edildi')),
        );
        // Refresh the list
        setState(() {
          _borrowedBooksFuture = _borrowService.getBorrowedBooks(widget.token);
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kitap iade edilemedi')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }
}
