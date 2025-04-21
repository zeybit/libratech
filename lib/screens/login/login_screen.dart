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
  final _nameController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isRegistering = false; // To toggle between login and register
  String _error = '';

  void _login() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    // Basic validation
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      setState(() {
        _error = 'İsim, e-posta ve şifre alanları boş bırakılamaz.';
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
        final userId = response['userId']; // Extract userId
        // Use provided name if available, otherwise use the name from response
        final userName =
            name.isNotEmpty
                ? name
                : response['name'] ?? response['user']?['name'] ?? 'Kullanıcı';

        // SharedPreferences ile token, userId ve kullanıcı bilgilerini sakla
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', role);
        await prefs.setString('userEmail', email); // Email bilgisini kaydet

        if (userId != null) {
          await prefs.setString('userId', userId);
        }

        // Kullanıcı adını kaydet - both from form input and response
        await prefs.setString('userName', userName);

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

  // Add register method
  void _register() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    // Basic validation
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Tüm alanlar doldurulmalıdır.';
      });
      return;
    }

    setState(() {
      _error = '';
    });

    try {
      final response = await _authService.register(name, email, password);

      if (response['success'] == true) {
        // Kayıt bilgilerini LocalStorage'a kaydet
        final userData = response['data'];
        if (userData != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userName', name);
          await prefs.setString('userEmail', email);
          await prefs.setString('userId', userData['id']);
          await prefs.setString('token', userData['token']);
        }

        // Registration successful, show success message and switch to login
        setState(() {
          _isRegistering = false;
          _error = '';
          // Do not clear name field when switching to login
          _emailController.clear();
          _passwordController.clear();

          // Show snackbar for success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kayıt başarılı! Şimdi giriş yapabilirsiniz.'),
            ),
          );
        });
      } else {
        setState(() {
          _error = response['message'];
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Kayıt yapılırken bir hata oluştu: $e';
      });
    }
  }

  // Toggle between login and register modes
  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegistering ? 'Kayıt Ol' : 'Giriş Yap')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Uygulama logosu veya ismi
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Column(
                children: [
                  const Icon(Icons.book, size: 80, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    'LibraTech',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  Text(
                    'Kütüphane Yönetim Sistemi',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            // Name field - Always visible
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isRegistering ? _register : _login,
              child: Text(_isRegistering ? 'Kayıt Ol' : 'Giriş Yap'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue[900],
              ),
            ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _error,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _toggleMode,
              child: Text(
                _isRegistering
                    ? 'Zaten hesabınız var mı? Giriş yapın'
                    : 'Hesabınız yok mu? Kayıt olun',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
