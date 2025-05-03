import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  final String baseUrl = 'http://localhost:5000/api';  // Backend URL'niz

  // Kullanıcıları listeleme
  Future<List<User>> getUsers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((userJson) => User.fromJson(userJson)).toList();
    } else {
      throw Exception('Kullanıcılar alınamadı: ${response.statusCode}');
    }
  }

  // Kullanıcı admin yetkisini güncelleme
  Future<void> updateUserAdminStatus(String token, String userId, bool isAdmin) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'isAdmin': isAdmin}),
    );

    if (response.statusCode != 200) {
      throw Exception('Kullanıcı yetkisi güncellenemedi: ${response.statusCode}');
    }
  }
}
