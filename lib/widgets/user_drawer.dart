import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/user/user_profile.dart';
import '../widgets/borrowed_books_screen.dart';

class UserDrawer extends StatefulWidget {
  final String token;
  final Function onLogout;

  const UserDrawer({Key? key, required this.token, required this.onLogout})
    : super(key: key);

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(_userName),
            accountEmail: Text(_userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: TextStyle(fontSize: 40.0, color: Colors.blue),
              ),
            ),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Ana Sayfa'),
            onTap: () {
              Navigator.pop(context); // Drawer'ı kapat
            },
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Ödünç Aldığım Kitaplar'),
            onTap: () {
              Navigator.pop(context); // Drawer'ı kapat
              // Direkt olarak sayfaya yönlendir
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => BorrowedBooksScreen(token: widget.token),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profil'),
            onTap: () {
              Navigator.pop(context); //
              // Direkt olarak sayfaya yönlendir
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(token: widget.token),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Çıkış Yap'),
            onTap: () {
              Navigator.pop(context);
              widget.onLogout();
            },
          ),
        ],
      ),
    );
  }
}
