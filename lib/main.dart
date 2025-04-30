import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/user/userHome_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/register_screen.dart';
import 'screens/user/user_profile.dart';
import 'widgets/borrowed_books_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final prefs = snapshot.data!;
        final token = prefs.getString('token');
        final role = prefs.getString('role');

        Widget home;
        if (token != null) {
          if (role == 'admin') {
            home = const AdminHomeScreen();
          } else {
            home = UserHomeScreen(token: token);
          }
        } else {
          home = const LoginScreen();
        }

        return MaterialApp(
          title: 'Libratech',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: home,
          routes: {
            '/signup': (_) => const SignUpScreen(),
            '/profile': (_) => token != null
                ? UserProfileScreen(token: token)
                : const LoginScreen(),
            '/borrowed-books': (_) => token != null
                ? BorrowedBooksScreen(token: token)
                : const LoginScreen(),
          },
        );
      },
    );
  }
}
