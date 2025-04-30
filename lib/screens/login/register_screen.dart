import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agree = true;

  static const Color mainBrown = Colors.brown;

  bool isValidEmail(String value) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Image(image: AssetImage('assets/logo.png'), height: 100),
              const SizedBox(height: 20),
              const Text(
                'Yeni Hesap Oluştur',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: mainBrown),
              ),
              const SizedBox(height: 20),

              // E-posta
              buildTextField(
                controller: _emailController,
                icon: Icons.email_outlined,
                label: 'E-Posta',
                hint: 'E-postanızı girin',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'E-posta boş olamaz';
                  if (!isValidEmail(value)) return 'Geçerli bir e-posta girin';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Şifre
              buildTextField(
                controller: _passwordController,
                icon: Icons.lock_outline,
                label: 'Parola',
                hint: 'Parolanızı girin',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: mainBrown,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Parola boş olamaz';
                  if (value.length < 6) return 'Parola en az 6 karakter olmalı';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Şifre tekrar
              buildTextField(
                controller: _confirmController,
                icon: Icons.lock_outline,
                label: 'Parolayı Onayla',
                hint: 'Parolanızı tekrar girin',
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    color: mainBrown,
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Bu alan boş olamaz';
                  if (value != _passwordController.text) return 'Parolalar uyuşmuyor';
                  return null;
                },
              ),

              Row(
                children: [
                  Checkbox(
                    value: _agree,
                    onChanged: (val) => setState(() => _agree = val ?? false),
                  ),
                  const Text('Şartları'),
                  Text(' kabul ediyorum', style: TextStyle(color: Colors.blue[700])),
                ],
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainBrown,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate() && _agree) {
                    Navigator.pushNamed(context, '/favorites');
                  }
                },
                child: const Text('Kayıt Ol', style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: () {},
                child: const Text("Kütüphane sahibi olarak devam et", style: TextStyle(color: mainBrown)),
              ),

              const Divider(height: 40),
              const Text('Veya sosyal medya ile kayıt ol', textAlign: TextAlign.center, style: TextStyle(color: mainBrown)),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.g_mobiledata, size: 30, color: mainBrown),
                  ),
                  SizedBox(width: 20),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.apple, size: 26, color: mainBrown),
                  ),
                  SizedBox(width: 20),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.facebook, size: 26, color: mainBrown),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Zaten bir hesabınız var mı? ", style: TextStyle(color: mainBrown)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text("Giriş Yap", style: TextStyle(fontWeight: FontWeight.bold, color: mainBrown)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        cursorColor: mainBrown,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(icon, color: mainBrown),
          labelText: label,
          labelStyle: const TextStyle(color: mainBrown),
          hintText: hint,
          hintStyle: const TextStyle(color: mainBrown),
          suffixIcon: suffixIcon,
        ),
        style: const TextStyle(color: mainBrown),
        validator: validator,
      ),
    );
  }
}
