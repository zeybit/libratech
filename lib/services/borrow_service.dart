import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BorrowService {
  // Use your backend URL here, replace with your actual URL if needed
  final String baseUrl = 'http://localhost:5000/api';

  // Kitap ödünç alma
  Future<Map<String, dynamic>> borrowBook(
    String token,
    String bookId,
    String userId,
  ) async {
    try {
      // Get the token from SharedPreferences if not provided
      if (token.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('token') ?? '';
        if (token.isEmpty) {
          return {
            'success': false,
            'message': 'Oturum açılmamış, lütfen giriş yapın.',
          };
        }
      }

      // Make sure userId is available
      if (userId.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        userId = prefs.getString('userId') ?? '';
        if (userId.isEmpty) {
          return {
            'success': false,
            'message':
                'Kullanıcı bilgisi bulunamadı. Lütfen tekrar giriş yapın.',
          };
        }
      }

      print(
        'Sending borrow request with: Token=${token.substring(0, 10)}..., BookId=$bookId, UserId=$userId',
      );

      final response = await http.post(
        Uri.parse('$baseUrl/borrow'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'bookId': bookId,
          'userId': userId, // Include userId in the request
          'dueDate': DateTime.now().add(Duration(days: 14)).toIso8601String(),
        }),
      );

      print('Response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Kitap başarıyla ödünç alındı.'};
      } else {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 'Bir hata oluştu.';
        } catch (_) {
          errorMessage = 'Sunucu hatası: ${response.statusCode}';
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Borrow exception: ${e.toString()}');
      return {'success': false, 'message': 'Bağlantı hatası: ${e.toString()}'};
    }
  }

  // Kitap iade etme
  Future<bool> returnBook(String token, String borrowId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/borrows/return'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'borrowId': borrowId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Return book error: $e');
      return false;
    }
  }

  // Implement the getUserBorrows method
  Future<List<Map<String, dynamic>>> getUserBorrows(
    String token,
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/borrows/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('Failed to load borrowed books: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting borrowed books: $e');
      return [];
    }
  }

  // Tüm ödünç alma işlemlerini listele (admin için)
  Future<List<Map<String, dynamic>>> getAllBorrows(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/borrows'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((borrow) => borrow as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Get all borrows error: $e');
      return [];
    }
  }

  // Add this method inside the BorrowService class
  Future<List<Map<String, dynamic>>> getBorrowedBooks(String token) async {
    try {
      // Get the user ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        print('User ID not found in SharedPreferences');
        return [];
      }

      // Use the correct endpoint format - userId as part of the path, not a query parameter
      final response = await http.get(
        Uri.parse('$baseUrl/borrows/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('Failed to load borrowed books: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting borrowed books: $e');
      return [];
    }
  }
}
