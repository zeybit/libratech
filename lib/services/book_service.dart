import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/book_model.dart';

class BookService {
  final String baseUrl = 'http://localhost:5000/api';

  // Kitapları almak
  Future<List<Book>> getBooks(String token) async {
    print('Kullanılan token: $token');
    final response = await http.get(
      Uri.parse('$baseUrl/books'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        // JSON verisini Book nesnelerine dönüştür
        return List<Book>.from(
            decoded.map((bookJson) => Book.fromJson(bookJson)));
      } catch (e) {
        throw Exception('JSON parse edilemedi');
      }
    } else {
      throw Exception('Kitaplar alınamadı');
    }
  }

  // Kitap eklemek
  Future<void> addBook({
    required String token,
    required String title,
    required String author,
    required String isbn,
    required int publishYear,
    required String publisher,
    required int pages,
    required String language,
    required String genre,
    required String description,
    required String coverImage,
    required bool available,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books'), // URL burada düzeltildi
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'author': author,
        'isbn': isbn,
        'publishYear': publishYear,
        'publisher': publisher,
        'pages': pages,
        'language': language,
        'genre': genre,
        'description': description,
        'coverImage': coverImage,
        'available': available,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Kitap eklenemedi: ${response.body}');
    }
  }

  // Kitap güncellemek
  Future<void> updateBook(String token,
      String id,
      String title,
      String author,) async {
    final response = await http.put(
      Uri.parse('$baseUrl/books/$id'), // URL burada düzeltildi
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'title': title, 'author': author}),
    );

    if (response.statusCode != 200) {
      throw Exception('Kitap güncellenemedi');
    }
  }

  Future<void> deleteBook(String token, String bookId) async {
    if (bookId.isEmpty) {
      throw Exception("Geçersiz kitap ID'si");
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/books/$bookId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Başarıyla silindi
        print('Kitap başarıyla silindi.');
      } else if (response.statusCode == 401) {
        // Token geçersizse
        throw Exception('Geçersiz token');
      } else {
        // Diğer hata durumları
        throw Exception('Kitap silinemedi: ${response.body}');
      }
    } catch (e) {
      print('Hata oluştu: $e');
      throw Exception('Kitap silme işlemi başarısız: $e');
    }
  }

}
