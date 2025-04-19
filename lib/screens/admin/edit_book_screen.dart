import 'package:flutter/material.dart';

import '../../services/book_service.dart';

class EditBookScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> book;

  const EditBookScreen({super.key, required this.token, required this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  final _bookService = BookService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book['title']);
    _authorController = TextEditingController(text: widget.book['author']);
  }

  void _updateBook() async {
    final title = _titleController.text;
    final author = _authorController.text;

    if (title.isNotEmpty && author.isNotEmpty) {
      await _bookService.updateBook(
        widget.token,
        widget.book['id'],
        title,
        author,
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kitap Güncelle')),
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
            ElevatedButton(
              onPressed: _updateBook,
              child: const Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }
}
