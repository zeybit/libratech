class User {
  final String? id;
  final String name;
  final String email;
  late final bool isAdmin;

  User({
    this.id,
    required this.name,
    required this.email,
    this.isAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'isAdmin': isAdmin};
  }
}
