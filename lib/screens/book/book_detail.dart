import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookDetailScreen extends StatefulWidget {
  final String bookId;
  // Make token optional since we removed authentication from the API
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
      print('Fetching book details for ID: ${widget.bookId}');

      final response = await http.get(
        Uri.parse('http://localhost:5000/api/books/${widget.bookId}'),
        headers: {
          'Content-Type': 'application/json',
          // Only include Authorization if token is provided
          if (widget.token != null) 'Authorization': 'Bearer ${widget.token}',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

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
      print('Exception: $e');
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
        title: Text(bookData?['title'] ?? 'Kitap Detayları'),
        backgroundColor: Colors.blue[900],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(
                child: Text(errorMessage, style: TextStyle(color: Colors.red)),
              )
              : _buildBookDetails(),
    );
  }

  Widget _buildBookDetails() {
    // Handle publishYear instead of publishedDate
    String publishYear = '';
    if (bookData?['publishYear'] != null) {
      publishYear = bookData!['publishYear'].toString();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover image
          if (bookData?['coverImage'] != null)
            Center(
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Image.network(
                  bookData!['coverImage'],
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 250,
                        width: 170,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.book,
                          size: 50,
                          color: Colors.grey,
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

          // Title
          Text(
            bookData?['title'] ?? 'Başlık yok',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          // Author
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

          // Published Year - Changed from publishedDate to publishYear
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

          // Page Count - Changed from pageCount to pages
          Row(
            children: [
              const Text(
                'Sayfa Sayısı: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bookData?['pages']?.toString() ?? 'Belirtilmemiş'),
            ],
          ),

          // Language field
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

          // Genre field
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

          // Description
          const Text(
            'Açıklama:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(bookData?['description'] ?? 'Açıklama yok'),

          const SizedBox(height: 24),

          // Availability status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  bookData?['available'] == true
                      ? Colors.green[100]
                      : Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  bookData?['available'] == true
                      ? Icons.check_circle
                      : Icons.cancel,
                  color:
                      bookData?['available'] == true
                          ? Colors.green[700]
                          : Colors.red[700],
                ),
                const SizedBox(width: 8),
                Text(
                  bookData?['available'] == true ? 'Mevcut' : 'Ödünç Verilmiş',
                  style: TextStyle(
                    color:
                        bookData?['available'] == true
                            ? Colors.green[700]
                            : Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Borrow button if available
          if (bookData?['available'] == true)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Implement book borrowing functionality here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kitap ödünç alma isteği gönderildi'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
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
