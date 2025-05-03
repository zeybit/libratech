import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/widgets/auth_wrapper.dart';

import 'screens/user/userHome_screen.dart';
import 'screens/user/user_profile.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/login/login_screen.dart';
import 'widgets/borrowed_books_screen.dart';
import 'providers/user_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.tryAutoLogin();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Libratech',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:
      _isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home':
            (context) => Consumer<UserProvider>(
          builder:
              (ctx, userProvider, _) =>
              UserHomeScreen(token: userProvider.token),
        ),
        '/admin': (context) => const AdminHomeScreen(token: '',),
        '/profile':
            (context) => Consumer<UserProvider>(
          builder:
              (ctx, userProvider, _) =>
              UserProfileScreen(token: userProvider.token),
        ),
        '/borrowed-books':
            (context) => Consumer<UserProvider>(
          builder:
              (ctx, userProvider, _) =>
              BorrowedBooksScreen(token: userProvider.token),
        ),
      },
      onGenerateRoute: (settings) {
        // Dinamik route oluşturma için ek özellikler
        if (settings.name == '/profile') {
          return MaterialPageRoute(
            builder: (context) {
              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              return userProvider.isAuthenticated
                  ? UserProfileScreen(token: userProvider.token)
                  : const LoginScreen();
            },
          );
        } else if (settings.name == '/borrowed-books') {
          return MaterialPageRoute(
            builder: (context) {
              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              return userProvider.isAuthenticated
                  ? BorrowedBooksScreen(token: userProvider.token)
                  : const LoginScreen();
            },
          );
        }
        return null;
      },
    );
  }
}
