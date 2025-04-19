import 'package:flutter/material.dart';
import '../services/book_service.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookService _bookService = BookService();
  late Future<List<dynamic>> _bookListFuture;

  @override
  void initState() {
    super.initState();
    _bookListFuture = _bookService.getBooks(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kitaplar")),
      body: FutureBuilder<List<dynamic>>(
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
                title: Text(book['title'] ?? 'Başlıksız'),
                subtitle: Text(book['author'] ?? 'Yazar bilinmiyor'),
              );
            },
          );
        },
      ),
    );
  }
}
