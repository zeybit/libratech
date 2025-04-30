// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Use the actual IP address instead of localhost if testing on a real device
  // If testing on a real device, use your computer's IP address instead of localhost
  static const String baseUrl = 'http://localhost:5000/api';

  // Update the login method to include any potentially missing fields
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Print the request before sending it
      print(
        'Login request: ${jsonEncode({'email': email, 'password': password})}',
      );

      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          // You may need additional fields based on your backend API requirements
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': data['token'],
          'userId':
              data['userId'] ?? data['user']?['_id'], // Try to extract userId
          'role': data['role'] ?? data['user']?['role'] ?? 'user',
        };
      } else {
        // Return the error message from the server
        return {
          'success': false,
          'message': data['message'] ?? 'Giriş başarısız',
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Add the user registration method
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Kayıt başarısız',
        };
      }
    } catch (e) {
      print('Registration error: $e');
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }
}
