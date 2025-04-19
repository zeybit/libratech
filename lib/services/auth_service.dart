// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Use the actual IP address instead of localhost if testing on a real device
  // If testing on a real device, use your computer's IP address instead of localhost
  final String baseUrl = 'http://localhost:5000/api';

  // Giriş işlemi ve token döndürme
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': data['token'],
          'role': data['role'] ?? 'user',
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
