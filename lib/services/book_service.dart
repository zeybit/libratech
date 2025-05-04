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
          decoded.map((bookJson) => Book.fromJson(bookJson)),
        );
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

  // Kitap detayını ID'ye göre almak
  Future<Book> getBookById(String token, String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/books/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        return Book.fromJson(decoded);
      } catch (e) {
        throw Exception('JSON parse edilemedi: $e');
      }
    } else {
      throw Exception('Kitap detayları alınamadı: ${response.statusCode}');
    }
  }

  // Kitabı tüm alanlarıyla güncellemek
  Future<void> updateBookFull({
    required String token,
    required String id,
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
    final response = await http.put(
      Uri.parse('$baseUrl/books/$id'),
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

    if (response.statusCode != 200) {
      throw Exception('Kitap güncellenemedi: ${response.body}');
    }
  }

  // Kitap güncellemek
  Future<void> updateBook(
    String token,
    String id,
    String title,
    String author,
  ) async {
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
    print("Deleting book with ID: $bookId");
    print("Using token: $token"); // Log full token for debugging

    if (bookId.isEmpty) {
      throw Exception("Book ID cannot be empty");
    }

    if (token.isEmpty) {
      throw Exception("Token cannot be empty");
    }

    final url = Uri.parse('$baseUrl/books/$bookId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Delete response status: ${response.statusCode}");

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete book: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print("Error in deleteBook: $e");
      rethrow;
    }
  }
}
