import 'package:flutter/material.dart';

import '../../services/book_service.dart';

class AddBookScreen extends StatefulWidget {
  final String token;
  const AddBookScreen({super.key, required this.token});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _bookService = BookService();

  void _saveBook() async {
    final title = _titleController.text;
    final author = _authorController.text;

    if (title.isNotEmpty && author.isNotEmpty) {
      await _bookService.addBook(widget.token, title, author);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kitap Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Kitap Adı'),
            ),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Yazar'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveBook, child: const Text('Kaydet')),
          ],
        ),
      ),
    );
  }
}
