import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/user/userHome_screen.dart';
import 'screens/user/user_profile.dart'; // User profile screen import
import 'screens/admin/admin_home_screen.dart';
import 'screens/login/login_screen.dart';
import 'widgets/borrowed_books_screen.dart'; // Move this to a separate file

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Dinamik route oluşturma
        if (settings.name == '/profile') {
          return MaterialPageRoute(
            builder:
                (context) =>
                    token != null
                        ? UserProfileScreen(token: token!)
                        : const LoginScreen(),
          );
        } else if (settings.name == '/borrowed-books') {
          return MaterialPageRoute(
            builder:
                (context) =>
                    token != null
                        ? BorrowedBooksScreen(token: token!)
                        : const LoginScreen(),
          );
        }
        // Default route
        return MaterialPageRoute(builder: (context) => _getHomeScreen());
      },
      routes: {'/': (context) => _getHomeScreen()},
    );
  }

  Widget _getHomeScreen() {
    if (token != null) {
      if (role == 'admin') {
        return AdminHomeScreen();
      } else {
        return UserHomeScreen(token: token!);
      }
    } else {
      return const LoginScreen();
    }
  }
}
