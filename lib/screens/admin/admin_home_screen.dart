import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Ana Sayfa')),
      body: Center(child: Text('Admin için ana sayfa')),
    );
  }
}
