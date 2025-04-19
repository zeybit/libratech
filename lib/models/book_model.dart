class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final bool available;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.available,
  });

  // JSON'dan veri modeline dönüştürme
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      isbn: json['isbn'],
      available: json['available'],
    );
  }
}
