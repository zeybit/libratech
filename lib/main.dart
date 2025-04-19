import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/user/userHome_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/login/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final role = prefs.getString('role');

  runApp(MyApp(token: token, role: role));
}

class MyApp extends StatelessWidget {
  final String? token;
  final String? role;

  const MyApp({super.key, this.token, this.role});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Libratech',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:
          token != null
              ? (role == 'admin'
                  ? const AdminHomeScreen()
                  : UserHomeScreen(token: token!)) // const kaldırıldı
              : const LoginScreen(),
    );
  }
}
