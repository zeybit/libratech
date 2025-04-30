import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  final String token;

  const UserProfileScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Kullanıcı';
      _userEmail = prefs.getString('userEmail') ?? 'kullanici@ornek.com';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6D4C41), // Koyu kahverengi
        title: const Text('Kullanıcı Profili', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kullanıcı Avatarı
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFF6D4C41), // Orta kahverengi
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                  style: TextStyle(fontSize: 50.0, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Kullanıcı Bilgileri
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              color: Color(0xFFF5E1DC), // Açık bej rengi
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(Icons.person, color: Color(0xFF3E2723)),
                      title: Text('İsim', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_userName),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.email, color: Color(0xFF3E2723)),
                      title: Text('E-posta', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_userEmail),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Şifre Değiştirme Butonu
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bu özellik henüz hazır değil')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6D4C41), // Orta kahverengi
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: Text(
                  'Şifremi Değiştir',
                  style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold,
                  color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
