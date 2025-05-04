import 'package:flutter/material.dart';
import '../services/borrow_service.dart';

class BorrowedBooksScreen extends StatefulWidget {
  final String token;

  const BorrowedBooksScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<BorrowedBooksScreen> createState() => _BorrowedBooksScreenState();
}

class _BorrowedBooksScreenState extends State<BorrowedBooksScreen> {
  final BorrowService _borrowService = BorrowService();
  late Future<List<Map<String, dynamic>>> _borrowedBooksFuture;

  @override
  void initState() {
    super.initState();
    _borrowedBooksFuture = _borrowService.getBorrowedBooks(widget.token);
  }

  Future<void> _returnBook(String borrowId) async {
    try {
      final success = await _borrowService.returnBook(widget.token, borrowId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kitap başarıyla iade edildi')),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödünç Aldığım Kitaplar'),
        backgroundColor: Colors.blue[900],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _borrowedBooksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Ödünç alınmış kitap bulunmamaktadır."),
            );
          }

          final books = snapshot.data!;
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              // Get the book information - adapt this based on your actual API response structure
              final bookInfo = book['book'] is Map ? book['book'] : {};
              final String title =
                  bookInfo['title'] ?? book['bookTitle'] ?? 'Başlık yok';
              final String author =
                  bookInfo['author'] ?? book['bookAuthor'] ?? 'Yazar yok';
              final DateTime? borrowDate =
                  book['borrowDate'] != null
                      ? DateTime.parse(book['borrowDate'])
                      : null;
              final DateTime? dueDate =
                  book['dueDate'] != null
                      ? DateTime.parse(book['dueDate'])
                      : null;
              final String id = book['_id'] ?? '';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(author),
                      if (borrowDate != null)
                        Text('Alınma Tarihi: ${_formatDate(borrowDate)}'),
                      if (dueDate != null)
                        Text(
                          'İade Tarihi: ${_formatDate(dueDate)}',
                          style: TextStyle(
                            color:
                                DateTime.now().isAfter(dueDate)
                                    ? Colors.red
                                    : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _returnBook(id),
                    child: const Text('İade Et'),
                  ),
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
}
