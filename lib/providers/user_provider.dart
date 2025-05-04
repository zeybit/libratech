import 'package:flutter/material.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProvider with ChangeNotifier {
  User? _user;
  String _token = '';
  bool _isAuthenticated = false;

  User? get user => _user;
  String get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _user?.isAdmin ?? false;

  // JWT token'dan payload kısmını çıkarıp decode eden yardımcı fonksiyon
  Map<String, dynamic> _parseJwt(String token) {
    if (token.isEmpty) return {};

    final parts = token.split('.');
    if (parts.length != 3) return {};

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));

    return json.decode(resp);
  }

  void setUser(User user, String token) {
    _user = user;
    _token = token;
    _isAuthenticated = true;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _token = '';
    _isAuthenticated = false;
    notifyListeners();
  }

  // Load user data from SharedPreferences on app start
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      return false;
    }

    // Set the token in the provider
    _token = token;

    // Load user info from preferences
    final userId = prefs.getString('userId') ?? '';
    final userName = prefs.getString('userName') ?? '';
    final userEmail = prefs.getString('userEmail') ?? '';
    final isAdmin = prefs.getBool('isAdmin') ?? false;

    _user = User(
      id: userId,
      name: userName,
      email: userEmail,
      isAdmin: isAdmin,
    );

    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _user = null;
    _token = '';
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}
