import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String token; // Şimdilik kullanılmıyor ama yapıyı koruyoruz
  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, String>>> _bookListFuture;

  @override
  void initState() {
    super.initState();
    _bookListFuture = _loadMockBooks();
  }

  // Sahte kitap verilerini döndüren fonksiyon
  Future<List<Map<String, String>>> _loadMockBooks() async {
    await Future.delayed(const Duration(seconds: 1)); // Yükleniyormuş gibi
    return [
      {'title': 'Sefiller', 'author': 'Victor Hugo'},
      {'title': 'Suç ve Ceza', 'author': 'Dostoyevski'},
      {'title': 'Körlük', 'author': 'Jose Saramago'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kitaplar")),
      body: FutureBuilder<List<Map<String, String>>>(
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
