import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user.dart';

class AdminUserPage extends StatefulWidget {
  @override
  State<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminUserPage> {
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUsers();
  }

  Future<void> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://localhost:5000/api/users'), // endpoint örnek
      headers: {'Authorization': 'Bearer $token'},
    );
    print('Gönderilen token: $token');

    if (response.statusCode == 200) {
      final List decoded = json.decode(response.body);
      setState(() {
        users = decoded.map((json) => User.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kullanıcı Listesi')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: users.length,
                itemBuilder: (_, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user.name ?? 'İsimsiz'),
                    subtitle: Text(user.email ?? 'Email yok'),
                  );
                },
              ),
    );
  }
}
