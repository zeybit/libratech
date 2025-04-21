import 'dart:convert';
import 'package:http/http.dart' as http;

class BookService {
  final String baseUrl = 'http://localhost:5000/api';

  Future<List<Map<String, dynamic>>> getBooks(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/books'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Burayı kontrol etmemiz çok önemli

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(decoded);
      } catch (e) {
        throw Exception('JSON parse edilemedi');
      }
    } else {
      throw Exception('Kitaplar alınamadı');
    }
  }

  Future<void> addBook(String token, String title, String author) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'author': author,
        'isbn': '1234567890123', // örnek sabit ISBN
        'available': true,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Kitap eklenemedi');
    }
  }

  Future<void> updateBook(
    String token,
    String id,
    String title,
    String author,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/books/$id'),
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

  Future<void> deleteBook(String token, String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/books/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Kitap silinemedi');
    }
  }
}
