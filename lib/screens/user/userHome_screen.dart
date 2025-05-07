// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../services/borrow_service.dart';
import '../../widgets/user_drawer.dart';
import '../book/book_detail.dart';
import '../login/login_screen.dart';
import '../../theme/app_theme.dart'; // AppTheme'i import ediyoruz

class UserHomeScreen extends StatefulWidget {
  final String token;
  const UserHomeScreen({super.key, required this.token});

  @override
  State<UserHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<UserHomeScreen> {
  final BookService _bookService = BookService();
  final BorrowService _borrowService = BorrowService();
  late Future<List<Book>> _bookListFuture;
  String? _userId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true; // Varsayılan olarak grid görünümü kullanacağız

  // Tema renkleri - AppTheme üzerinden alınacak
  late Color primaryColor;
  late Color accentColor;
  late Color backgroundColor;
  late Color textPrimaryColor;
  late Color textSecondaryColor;
  late Color surfaceColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tema renklerini güncelleme
    final theme = Theme.of(context);
    primaryColor = theme.primaryColor;
    accentColor = theme.colorScheme.secondary;
    backgroundColor = theme.scaffoldBackgroundColor;
    textPrimaryColor = theme.textTheme.bodyLarge!.color!;
    textSecondaryColor = theme.textTheme.bodyMedium!.color!;
    surfaceColor = theme.cardColor;
  }

  @override
  void initState() {
    super.initState();
    _bookListFuture = _bookService.getBooks(widget.token);
    _getUserId();
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  // Kullanıcı çıkışı
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('role');

    // Login ekranına yönlendirme
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Kitap arama
  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _bookListFuture = _bookService.getBooks(widget.token);
      }
    });
  }

  void _borrowBook(String bookId) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu özellik henüz hazır değil.')),
      );
      return;
    }

    try {
      final borrowResult = await _borrowService.borrowBook(
        widget.token,
        bookId,
        _userId!,
      );

      if (borrowResult['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Kitap başarıyla ödünç alındı'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        // Kitap listesini yenile
        setState(() {
          _bookListFuture = _bookService.getBooks(widget.token);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(borrowResult['message'] ?? 'Kitap ödünç alınamadı'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // Ödünç alınan kitapları görüntüle
  void _viewBorrowedBooks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _BorrowedBooksScreen(token: widget.token),
      ),
    ).then((_) {
      // Kullanıcı geri döndüğünde kitap listesini yenile
      setState(() {
        _bookListFuture = _bookService.getBooks(widget.token);
      });
    });
  }

  // Görünüm modunu değiştir
  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Kitaplar"),
        elevation: 4,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Görünüm modu değiştirme butonu
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: _toggleViewMode,
            tooltip: _isGridView ? 'Liste Görünümü' : 'Grid Görünümü',
          ),
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: _viewBorrowedBooks,
            tooltip: 'Ödünç Aldıklarım',
          ),
        ],
      ),
      drawer: UserDrawer(token: widget.token, onLogout: _logout),
      body: Column(
        children: [
          // Arama kutusu
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Kitap Ara',
                hintText: 'Kitap adı veya yazar...',
                prefixIcon: Icon(Icons.search, color: primaryColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: textSecondaryColor),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
              onChanged: _performSearch,
            ),
          ),

          // Kitap listesi
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: _bookListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: accentColor),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Kitaplar yüklenirken bir hata oluştu",
                          style: TextStyle(
                            fontSize: 16,
                            color: textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${snapshot.error}",
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Henüz kitap eklenmemiş",
                          style: TextStyle(
                            fontSize: 18,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final books = snapshot.data!;

                // Arama sorgusu varsa, kitapları filtrele
                final filteredBooks =
                    _searchQuery.isEmpty
                        ? books
                        : books.where((book) {
                          final title = book.title.toLowerCase();
                          final author = book.author.toLowerCase();
                          return title.contains(_searchQuery) ||
                              author.contains(_searchQuery);
                        }).toList();

                if (filteredBooks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Arama sonucuna uygun kitap bulunamadı",
                          style: TextStyle(
                            fontSize: 18,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Grid görünümü veya liste görünümü
                if (_isGridView) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // İki sütunlu grid
                          childAspectRatio: 0.65, // Kitap orantısı
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return _buildBookGridItem(book);
                    },
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return _buildBookListItem(book);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Grid görünümü için kitap öğesi
  Widget _buildBookGridItem(Book book) {
    final bool isAvailable = book.available;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    BookDetailScreen(bookId: book.id, token: widget.token),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kitap kapağı
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Kitap resmi
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      image:
                          book.coverImage != null && book.coverImage!.isNotEmpty
                              ? DecorationImage(
                                image: NetworkImage(book.coverImage!),
                                fit: BoxFit.cover,
                              )
                              : const DecorationImage(
                                image: AssetImage(
                                  'assets/images/book_placeholder.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                    ),
                  ),
                  // Kitap durumu etiketi
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isAvailable ? 'Mevcut' : 'Ödünç',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Kitap bilgileri
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(fontSize: 12, color: textSecondaryColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (isAvailable)
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => _borrowBook(book.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Ödünç Al',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    if (!isAvailable)
                      Container(
                        width: double.infinity,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Mevcut Değil',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Liste görünümü için kitap öğesi

  // _buildBookListItem fonksiyonunu güncelliyoruz

  Widget _buildBookListItem(Book book) {
    final bool isAvailable = book.available;

    return Card(
      margin: const EdgeInsets.only(bottom: 12), // Margin azaltıldı
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2, // Gölge azaltıldı
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      BookDetailScreen(bookId: book.id, token: widget.token),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kitap resmi - boyut azaltıldı
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: SizedBox(
                width: 90, // Genişlik azaltıldı
                height: 130, // Yükseklik azaltıldı
                child:
                    book.coverImage != null && book.coverImage!.isNotEmpty
                        ? Image.network(
                          book.coverImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/book_placeholder.png',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                        : Image.asset(
                          'assets/images/book_placeholder.png',
                          fit: BoxFit.cover,
                        ),
              ),
            ),
            // Kitap bilgileri - daha kompakt
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  12,
                  12,
                  8,
                ), // Padding azaltıldı
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Minimum boyut
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            book.title,
                            style: const TextStyle(
                              fontSize: 14, // Font boyutu küçültüldü
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1, // Tek satıra sınırlandı
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, // Padding azaltıldı
                            vertical: 3, // Padding azaltıldı
                          ),
                          decoration: BoxDecoration(
                            color: isAvailable ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(
                              8,
                            ), // Radius azaltıldı
                          ),
                          child: Text(
                            isAvailable ? 'Mevcut' : 'Ödünç',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10, // Font boyutu küçültüldü
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4), // Boşluk azaltıldı
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 12, // Font boyutu küçültüldü
                        color: textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Kategori bilgisi koşullu olarak gösteriliyor
                    if (book.genre != null && book.genre!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 4,
                        ), // Padding azaltıldı
                        child: Text(
                          "Kategori: ${book.genre}",
                          style: TextStyle(
                            fontSize: 11, // Font boyutu küçültüldü
                            color: textSecondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 8), // Boşluk azaltıldı
                    if (isAvailable)
                      SizedBox(
                        height: 30, // Yükseklik azaltıldı
                        width: 100, // Genişlik azaltıldı
                        child: ElevatedButton(
                          onPressed: () => _borrowBook(book.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                8,
                              ), // Radius azaltıldı
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ), // Padding azaltıldı
                          ),
                          child: const Text(
                            'Ödünç Al',
                            style: TextStyle(
                              fontSize: 11,
                            ), // Font boyutu küçültüldü
                          ),
                        ),
                      ),
                    if (!isAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, // Padding azaltıldı
                          vertical: 5, // Padding azaltıldı
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Radius azaltıldı
                        ),
                        child: Text(
                          'Mevcut Değil',
                          style: TextStyle(
                            fontSize: 11, // Font boyutu küçültüldü
                            color: textSecondaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Ödünç alınan kitapları gösteren ekran
class _BorrowedBooksScreen extends StatefulWidget {
  final String token;

  const _BorrowedBooksScreen({Key? key, required this.token}) : super(key: key);

  @override
  _BorrowedBooksScreenState createState() => _BorrowedBooksScreenState();
}

class _BorrowedBooksScreenState extends State<_BorrowedBooksScreen> {
  final BorrowService _borrowService = BorrowService();
  late Future<List<Map<String, dynamic>>> _borrowedBooksFuture;

  // Tema renkleri
  late Color primaryColor;
  late Color accentColor;
  late Color backgroundColor;
  late Color textPrimaryColor;
  late Color textSecondaryColor;
  late Color surfaceColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tema renklerini güncelleme
    final theme = Theme.of(context);
    primaryColor = theme.primaryColor;
    accentColor = theme.colorScheme.secondary;
    backgroundColor = theme.scaffoldBackgroundColor;
    textPrimaryColor = theme.textTheme.bodyLarge!.color!;
    textSecondaryColor = theme.textTheme.bodyMedium!.color!;
    surfaceColor = theme.cardColor;
  }

  @override
  void initState() {
    super.initState();
    _borrowedBooksFuture = _borrowService.getBorrowedBooks(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Ödünç Aldığım Kitaplar'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _borrowedBooksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accentColor));
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ödünç alınan kitaplar yüklenirken bir hata oluştu',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: textPrimaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(fontSize: 14, color: textSecondaryColor),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz ödünç aldığınız kitap bulunmamaktadır',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: textSecondaryColor),
                  ),
                ],
              ),
            );
          }

          final borrowedBooks = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: borrowedBooks.length,
            itemBuilder: (context, index) {
              final book = borrowedBooks[index];
              final borrowDate =
                  book['borrowDate'] != null
                      ? DateTime.parse(book['borrowDate'])
                      : null;
              final returnDate =
                  book['returnDate'] != null
                      ? DateTime.parse(book['returnDate'])
                      : null;
              final bookcoverImage =
                  book['bookcoverImage'] ?? book['book']?['coverImage'] ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BookDetailScreen(
                              bookId:
                                  book['bookId'] ?? book['book']?['_id'] ?? '',
                              token: widget.token,
                            ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kitap resmi
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: SizedBox(
                          width: 100,
                          height: 140,
                          child:
                              bookcoverImage.isNotEmpty
                                  ? Image.network(
                                    bookcoverImage,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/book_placeholder.png',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                  : Image.asset(
                                    'assets/images/book_placeholder.png',
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                      // Kitap bilgileri
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book['bookTitle'] ??
                                    book['book']?['title'] ??
                                    'Başlık yok',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                book['bookAuthor'] ??
                                    book['book']?['author'] ??
                                    'Yazar yok',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (borrowDate != null)
                                _buildDateInfo(
                                  'Alınma Tarihi:',
                                  _formatDate(borrowDate),
                                ),
                              if (returnDate != null)
                                _buildDateInfo(
                                  'İade Tarihi:',
                                  _formatDate(returnDate),
                                ),
                              if (returnDate == null) ...[
                                _buildDateInfo(
                                  'Alınma Tarihi:',
                                  _formatDate(borrowDate!),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed:
                                      () => _returnBook(
                                        book['_id'] ?? book['id'],
                                      ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    minimumSize: const Size(120, 36),
                                  ),
                                  child: const Text('İade Et'),
                                ),
                              ],
                              if (returnDate != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green.shade700,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'İade Edildi',
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Tarih bilgi satırını oluşturan widget
  Widget _buildDateInfo(String label, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(date, style: TextStyle(fontSize: 13, color: textPrimaryColor)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _returnBook(String borrowId) async {
    try {
      final success = await _borrowService.returnBook(widget.token, borrowId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Kitap başarıyla iade edildi'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        // Listeyi yenile
        setState(() {
          _borrowedBooksFuture = _borrowService.getBorrowedBooks(widget.token);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Kitap iade edilemedi'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
