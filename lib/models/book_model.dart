class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final int publishYear;
  final String publisher;
  final int pages;
  final String language;
  final String genre;
  final String description;
  final String coverImage;
  final bool available;
  final DateTime createdAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.publishYear,
    required this.publisher,
    required this.pages,
    required this.language,
    required this.genre,
    required this.description,
    required this.coverImage,
    required this.available,
    required this.createdAt,
  });

  // JSON'dan Book objesine dönüşüm
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id']?.toString() ?? '', // ObjectId'yı string'e dönüştürme
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      isbn: json['isbn'] ?? '',
      publishYear: json['publishYear'] ?? 0,
      publisher: json['publisher'] ?? '',
      pages: json['pages'] ?? 0,
      language: json['language'] ?? '',
      genre: json['genre'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['coverImage'] ?? '',
      available: json['available'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? '1970-01-01T00:00:00.000Z'),
    );
  }

  // Book objesini JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'publishYear': publishYear,
      'publisher': publisher,
      'pages': pages,
      'language': language,
      'genre': genre,
      'description': description,
      'coverImage': coverImage,
      'available': available,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
