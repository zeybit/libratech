import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/login/login_screen.dart';

class AdminRoute extends StatelessWidget {
  final Widget child;

  const AdminRoute({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (!userProvider.isAuthenticated) {
      return const LoginScreen();
    }

    if (!userProvider.isAdmin) {
      // Redirect non-admin users to home
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin yetkisi gerekiyor')),
        );
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return child;
  }
}
