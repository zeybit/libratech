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

  bool _isRegistering = false;
  bool _obscurePassword = true;
  String _error = '';

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _login() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

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
        final userId = response['userId'];
        final userName = name.isNotEmpty
            ? name
            : response['name'] ?? response['user']?['name'] ?? 'Kullanıcı';

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', role);
        await prefs.setString('userEmail', email);
        await prefs.setString('userId', userId ?? '');
        await prefs.setString('userName', userName);

        if (!mounted) return;

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
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

  void _register() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

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
        final userData = response['data'];
        if (userData != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userName', name);
          await prefs.setString('userEmail', email);
          await prefs.setString('userId', userData['id']);
          await prefs.setString('token', userData['token']);
        }

        setState(() {
          _isRegistering = false;
          _error = '';
          _emailController.clear();
          _passwordController.clear();

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

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color mainBrown = const Color(0xFF6D4C41);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainBrown,
        title: Text(_isRegistering ? 'Kayıt Ol' : 'Giriş Yap'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Column(
                children: [
                  Icon(Icons.book, size: 80, color: mainBrown),
                  const SizedBox(height: 16),
                  Text(
                    'LibraTech',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: mainBrown,
                    ),
                  ),
                  Text(
                    'Kütüphane Yönetim Sistemi',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
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
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Şifre',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: mainBrown,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isRegistering ? _register : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: mainBrown,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isRegistering ? 'Kayıt Ol' : 'Giriş Yap',
                style: const TextStyle(color: Colors.white),
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
                style: TextStyle(color: mainBrown),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
