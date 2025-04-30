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

  final Color mainBrown = const Color(0xFF6D4C41);

  @override
  void initState() {
    super.initState();
    _borrowedBooksFuture = _borrowService.getBorrowedBooks(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainBrown,
        title: const Text('Ödünç Aldığım Kitaplar',
        style: TextStyle(color: Colors.white),),
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
              final DateTime? dueDate = book['dueDate'] != null
                  ? DateTime.parse(book['dueDate'])
                  : null;

              final bool gecikmisMi =
                  dueDate != null && DateTime.now().isAfter(dueDate);

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.menu_book, color: mainBrown),
                  title: Text(
                    book['title'] ?? 'Başlık yok',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: mainBrown,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book['author'] ?? 'Yazar yok'),
                      if (dueDate != null)
                        Text(
                          'İade Tarihi: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                          style: TextStyle(
                            color: gecikmisMi ? Colors.red : Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  trailing: ElevatedButton.icon(
                    icon: const Icon(Icons.undo),
                    label: const Text('İade Et'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6D4C41),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('İade özelliği henüz eklenmedi'),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
