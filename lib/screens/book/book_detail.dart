import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookDetailScreen extends StatefulWidget {
  final String bookId;
  final String? token;

  const BookDetailScreen({Key? key, required this.bookId, this.token})
      : super(key: key);

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool isLoading = true;
  Map<String, dynamic>? bookData;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchBookDetails();
  }

  Future<void> fetchBookDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/books/${widget.bookId}'),
        headers: {
          'Content-Type': 'application/json',
          if (widget.token != null) 'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          bookData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Kitap bilgileri yüklenemedi: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Bağlantı hatası: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookData?['title'] ?? 'Kitap Detayları',
        style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF6D4C41), // Kahverengi tonlarında
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(errorMessage, style: TextStyle(color: Colors.red)),
      )
          : _buildBookDetails(),
    );
  }

  Widget _buildBookDetails() {
    String publishYear = '';
    if (bookData?['publishYear'] != null) {
      publishYear = bookData!['publishYear'].toString();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover image with shadow and rounded corners
          if (bookData?['coverImage'] != null)
            Center(
              child: Container(
                height: 250,
                width: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    bookData!['coverImage'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.book, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            )
          else
            Center(
              child: Container(
                height: 250,
                width: 170,
                color: Colors.grey[300],
                child: const Icon(Icons.book, size: 50, color: Colors.grey),
              ),
            ),

          const SizedBox(height: 24),

          // Title with larger font size
          Text(
            bookData?['title'] ?? 'Başlık yok',
            style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: Colors.brown),
          ),

          const SizedBox(height: 8),

          // Author with improved styling
          Row(
            children: [
              const Text(
                'Yazar: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bookData?['author'] ?? 'Belirtilmemiş'),
            ],
          ),

          const SizedBox(height: 8),

          // ISBN
          Row(
            children: [
              const Text(
                'ISBN: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bookData?['isbn'] ?? 'Belirtilmemiş'),
            ],
          ),

          const SizedBox(height: 8),

          // Published Year
          Row(
            children: [
              const Text(
                'Yayın Yılı: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(publishYear.isNotEmpty ? publishYear : 'Belirtilmemiş'),
            ],
          ),

          const SizedBox(height: 8),

          // Publisher
          Row(
            children: [
              const Text(
                'Yayınevi: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bookData?['publisher'] ?? 'Belirtilmemiş'),
            ],
          ),

          const SizedBox(height: 8),

          // Page Count
          Row(
            children: [
              const Text(
                'Sayfa Sayısı: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bookData?['pages']?.toString() ?? 'Belirtilmemiş'),
            ],
          ),

          // Language
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Dil: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bookData?['language'] ?? 'Belirtilmemiş'),
            ],
          ),

          // Genre
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Tür: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bookData?['genre'] ?? 'Belirtilmemiş'),
            ],
          ),

          const SizedBox(height: 16),

          // Description with more padding
          const Text(
            'Açıklama:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(bookData?['description'] ?? 'Açıklama yok'),

          const SizedBox(height: 24),

          // Availability status with a colored container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bookData?['available'] == true
                  ? Colors.green[100]
                  : Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  bookData?['available'] == true
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: bookData?['available'] == true
                      ? Colors.green[700]
                      : Colors.red[700],
                ),
                const SizedBox(width: 8),
                Text(
                  bookData?['available'] == true ? 'Mevcut' : 'Ödünç Verilmiş',
                  style: TextStyle(
                    color: bookData?['available'] == true
                        ? Colors.green[700]
                        : Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Borrow button
          if (bookData?['available'] == true)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kitap ödünç alma isteği gönderildi'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[800], // Kahverengi buton
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Ödünç Al', style: TextStyle(fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }
}
