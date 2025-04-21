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
              final DateTime? dueDate =
                  book['dueDate'] != null
                      ? DateTime.parse(book['dueDate'])
                      : null;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(book['title'] ?? 'Başlık yok'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book['author'] ?? 'Yazar yok'),
                      if (dueDate != null)
                        Text(
                          'İade Tarihi: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
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
                    onPressed: () {
                      // İade işlemi eklenebilir
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('İade özelliği henüz eklenmedi'),
                        ),
                      );
                    },
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
}
