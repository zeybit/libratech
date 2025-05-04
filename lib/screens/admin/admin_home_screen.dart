import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/screens/admin/users_manager.dart';
import '../../providers/user_provider.dart';
import '../../widgets/admin_route.dart';
import 'book_management_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  final String token; // Token parametresi eklendi
  const AdminHomeScreen({Key? key, required this.token})
    : super(key: key); // token parametresi const yapıcıya eklendi

  @override
  Widget build(BuildContext context) {
    final Color mainBrown = const Color(0xFF6D4C41); // Kahverengi tonu

    return AdminRoute(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Paneli'),
          backgroundColor: mainBrown, // AppBar rengi
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );
                await userProvider.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Admin Paneline Hoş Geldiniz',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Başlık rengi
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildAdminFeature(
                context,
                'Kitap Yönetimi',
                Icons.book,
                'Kitapları ekle, düzenle veya sil.',
                () {
                  print("Passing token to BookManagementScreen: $token");
                  // Around line 50-60 where you navigate to BookManagementScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BookManagementScreen(
                            // Get token from provider instead of using the local variable
                            token: token,
                          ),
                    ),
                  );
                },
                mainBrown,
              ),
              const SizedBox(height: 16),
              _buildAdminFeature(
                context,
                'Kullanıcı Yönetimi',
                Icons.people,
                'Kullanıcıları gör.',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminUserPage(), // token geçildi
                    ),
                  );
                },
                mainBrown,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminFeature(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 48, color: color), // Ikon rengi
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color, // Başlık rengi
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(description),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
