import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../profile/viewmodels/notification_viewmodel.dart';

import '../viewmodels/home_viewmodel.dart';
import '../models/book_model.dart';
import '../repositories/book_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/book_cover_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  final TextEditingController _searchController = TextEditingController();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return 'Günaydın,';
    if (hour >= 12 && hour < 18) return 'İyi Günler,';
    if (hour >= 18 && hour < 22) return 'İyi Akşamlar,';
    return 'İyi Geceler,';
  }

  Widget _buildAvatar(BuildContext context, String? displayName, String? photoUrl) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = (displayName != null && displayName.length >= 2)
        ? displayName.substring(0, 2).toUpperCase()
        : (displayName?.isNotEmpty == true ? displayName!.substring(0, 1).toUpperCase() : '?');

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(photoUrl),
        backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: colorScheme.primary,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSearchActive = viewModel.searchQuery.isNotEmpty;

    // Get user data from AuthViewModel instead of direct Firebase call
    // This ensures UI updates immediately when profile is changed
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;
    final displayName = user?.username ?? 'Kullanıcı';
    final photoUrl = user?.profilePhotoUrl;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: textTheme.bodyLarge?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        displayName,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Consumer<NotificationViewModel>(
                        builder: (context, navVM, child) {
                          return IconButton(
                            icon: Badge(
                              isLabelVisible: navVM.unreadCount > 0,
                              label: Text(navVM.unreadCount.toString()),
                              child: const Icon(LucideIcons.bell),
                            ),
                            onPressed: () => context.push('/notifications'),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildAvatar(context, displayName, photoUrl),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.search,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Kitap, yazar veya tür ara...',
                          border: InputBorder.none,
                          suffixIcon: isSearchActive
                              ? IconButton(
                                  icon: const Icon(LucideIcons.x, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<HomeViewModel>().clearSearch();
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          context.read<HomeViewModel>().searchBooks(value.trim());
                        },
                      ),
                    ),
                    if (viewModel.isSearching)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: viewModel.isLoading
                  ? _buildShimmerContent(context)
                  : isSearchActive
                      ? _buildSearchResults(context, viewModel, isDark)
                      : _buildHomeContent(context, viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, HomeViewModel viewModel, bool isDark) {
    if (viewModel.isSearching) {
      return ShimmerLoading(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 6,
          itemBuilder: (context, index) => const ListTileShimmer(),
        ),
      );
    }
    if (viewModel.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.bookX, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '"${viewModel.searchQuery}" için sonuç bulunamadı',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: viewModel.searchResults.length,
      itemBuilder: (context, index) {
        final book = viewModel.searchResults[index];
        return _SearchResultTile(book: book, isDark: isDark);
      },
    );
  }

  Widget _buildHomeContent(BuildContext context, HomeViewModel viewModel) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Currently Reading Section
          if (viewModel.currentlyReading.isNotEmpty) ...[
            _buildSectionTitle(context, 'Okuyorum'),
            const SizedBox(height: 12),
            SizedBox(
              height: 170,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: viewModel.currentlyReading.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _ReadingCard(book: viewModel.currentlyReading[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Popular Books Section
          _buildSectionTitle(context, 'Popüler Kitaplar'),
          const SizedBox(height: 12),
          _buildHorizontalList(viewModel.popularBooks),
          const SizedBox(height: 24),

          // Recommended Section
          _buildSectionTitle(context, 'Senin İçin Önerilenler'),
          const SizedBox(height: 12),
          _buildHorizontalList(viewModel.recommendedBooks),
          const SizedBox(height: 24),

          // Finished Books Section
          if (viewModel.finishedBooks.isNotEmpty) ...[
            _buildSectionTitle(context, 'Bitirdiklerim'),
            const SizedBox(height: 12),
            _buildHorizontalList(viewModel.finishedBooks),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<BookModel> books, {double height = 240}) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _BookCard(book: book),
          );
        },
      ),
    );
  }

  Widget _buildShimmerContent(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSectionTitle(context, 'Okuyorum'),
            const SizedBox(height: 12),
            const SizedBox(
              height: 170,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ReadingCardShimmer(),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Popüler Kitaplar'),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) => const BookCardShimmer(),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Senin İçin Önerilenler'),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) => const BookCardShimmer(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Okuyorum kartı — sayfa ilerlemesi gösterir
class _ReadingCard extends StatelessWidget {
  final BookModel book;
  const _ReadingCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasTotalPages = book.totalPages > 0;
    final progress = book.readingProgress;
    final percent = book.readingProgressPercent;

    return GestureDetector(
      onTap: () => context.push('/book/${book.id}'),
      child: Container(
        width: 310,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            BookCoverWidget(
              coverUrl: book.coverUrl,
              width: 80,
              height: 120,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: hasTotalPages ? progress : 0.0,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 6),
                  if (hasTotalPages)
                    GestureDetector(
                      onTap: () => _showPageDialog(context),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$percent% tamamlandı  ·  ${book.currentPage} / ${book.totalPages} sayfa',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                          Icon(LucideIcons.pencil, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ],
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => _showPageDialog(context),
                      child: Row(
                        children: [
                          Icon(LucideIcons.pencil, size: 12,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Sayfa bilgisi ekle',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPageDialog(BuildContext context) async {
    final currentPageCtrl = TextEditingController(
        text: book.currentPage > 0 ? '${book.currentPage}' : '');
    final totalPageCtrl = TextEditingController(
        text: book.totalPages > 0 ? '${book.totalPages}' : '');

    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Okuma İlerlemen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: totalPageCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Toplam Sayfa Sayısı',
                prefixIcon: Icon(LucideIcons.bookOpen),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: currentPageCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Şu An Kaçıncı Sayfadasın?',
                prefixIcon: Icon(LucideIcons.bookmark),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              final total = int.tryParse(totalPageCtrl.text) ?? 0;
              final current = int.tryParse(currentPageCtrl.text) ?? 0;
              Navigator.pop(ctx, {'current': current, 'total': total});
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        // ignore: use_build_context_synchronously
        final repo = context.read<HomeViewModel>();
        // We call repository directly through viewmodel reload after save
        await _savePages(uid, book.id, result['current']!, result['total']!);
        await repo.loadHomeData();
      }
    }
  }

  Future<void> _savePages(String uid, String bookId, int current, int total) async {
    // Use repository directly
    final repo = BookRepository();
    await repo.savePageProgress(uid, bookId, current, total);
  }
}

class _SearchResultTile extends StatelessWidget {
  final BookModel book;
  final bool isDark;

  const _SearchResultTile({super.key, required this.book, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/book/${book.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            BookCoverWidget(
              coverUrl: book.coverUrl,
              width: 60,
              height: 85,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  if (book.rating > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(LucideIcons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          book.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 18),
          ],
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookModel book;

  const _BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/book/${book.id}'),
      child: Container(
        width: 140,
        margin: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: BookCoverWidget(
                  coverUrl: book.coverUrl,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
