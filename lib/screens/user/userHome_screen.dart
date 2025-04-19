// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../../services/book_service.dart';

class UserHomeScreen extends StatefulWidget {
  final String token;
  const UserHomeScreen({super.key, required this.token});

  @override
  State<UserHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<UserHomeScreen> {
  final BookService _bookService = BookService();
  late Future<List<Map<String, dynamic>>> _bookListFuture;

  @override
  void initState() {
    super.initState();
    _bookListFuture = _bookService.getBooks(
      widget.token,
    ); // Token'ı göndererek kitapları al
  }

  // Kitap ödünç alma
  void _borrowBook(String id) async {
    await _bookService.borrowBook(widget.token, id); // Kitap ödünç al
    setState(() {
      _bookListFuture = _bookService.getBooks(
        widget.token,
      ); // Kitap listesine güncel veriyi al
    });
  }

  // Kitap iade etme
  void _returnBook(String id) async {
    await _bookService.returnBook(widget.token, id); // Kitap iade et
    setState(() {
      _bookListFuture = _bookService.getBooks(
        widget.token,
      ); // Kitap listesine güncel veriyi al
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kitaplar")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
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

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                title: Text(book['title'] ?? 'Başlık yok'),
                subtitle: Text(book['author'] ?? 'Yazar yok'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.library_books),
                      onPressed:
                          () =>
                              _borrowBook(book['id'].toString()), // Ödünç alma
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed:
                          () => _returnBook(book['id'].toString()), // İade etme
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
