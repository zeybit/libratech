import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../admin/admin_home_screen.dart';
import '../user/userHome_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  String _error = '';

  // ...existing code...

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Basic validation
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'E-posta ve şifre alanları boş bırakılamaz.';
      });
      return;
    }

    setState(() {
      _error = '';
    });

    try {
      final response = await _authService.login(email, password);

      if (response['success'] == true) {
        final token = response['token'];
        final role = response['role'];

        // SharedPreferences ile token'ı sakla
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', role);

        // Giriş başarılı, role göre yönlendir
        if (role == 'admin') {
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (_) => UserHomeScreen(token: token)),
          );
        }
      } else {
        setState(() {
          _error = response['message'];
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Giriş yapılırken bir hata oluştu: $e';
      });
    }
  }

  // ...existing code...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Şifre'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Giriş Yap')),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_error, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
