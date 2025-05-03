import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/admin/admin_home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/user/userHome_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Check if authenticated
    if (!userProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // Check if admin
    if (userProvider.isAdmin) {
      return const AdminHomeScreen(token: '',);
    }

    // Regular user
    return const UserHomeScreen(token: '');
  }
}
