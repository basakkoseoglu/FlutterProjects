import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../viewmodels/book_detail_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/book_cover_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load book data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookDetailViewModel>().loadBook(widget.bookId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BookDetailViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (viewModel.isLoading || viewModel.book == null) {
      return Scaffold(
        body: ShimmerLoading(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 350, color: Colors.white),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 24, width: 200, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 16, width: 120, color: Colors.white),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(3, (i) => Container(height: 60, width: 80, color: Colors.white)),
                      ),
                      const SizedBox(height: 32),
                      Container(height: 100, width: double.infinity, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final book = viewModel.book!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.5),
            child: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              child: IconButton(
                icon: const Icon(LucideIcons.moreVertical, color: Colors.white, size: 20),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image Header
            Stack(
              children: [
                BookCoverWidget(
                  coverUrl: book.coverUrl,
                  width: double.infinity,
                  height: 350,
                ),
                // Gradient overlay
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Book Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.author,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        book.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(120+ inceleme)',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatusSelector(
                      currentStatus: viewModel.currentStatus,
                      onChanged: (newStatus) {
                        viewModel.updateStatus(newStatus);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Synopsis
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Özet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    book.description,
                    style: TextStyle(
                      height: 1.5,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Go to Community
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    context.push('/book/${book.id}/community?title=${Uri.encodeComponent(book.title)}');
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(LucideIcons.messageCircle, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Topluluk Tartışması',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text('Aktif tartışma konuları')
                            ],
                          ),
                        ),
                        const Icon(LucideIcons.chevronRight),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onChanged;

  const _StatusSelector({
    Key? key,
    required this.currentStatus,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: ['Want to Read', 'Reading', 'Finished', 'Dropped'].contains(currentStatus)
              ? currentStatus
              : 'Want to Read', // Default fallback
          icon: const Icon(LucideIcons.chevronDown, color: Colors.white),
          dropdownColor: Theme.of(context).colorScheme.surface,
          isExpanded: true,
          alignment: Alignment.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
          ),
          items: [
            DropdownMenuItem(
              value: 'Want to Read',
              child: Center(
                child: Text(
                  'Okumak İstiyorum',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Reading',
              child: Center(
                child: Text(
                  'Okuyorum',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Finished',
              child: Center(
                child: Text(
                  'Bitti',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
            DropdownMenuItem(
              value: 'Dropped',
              child: Center(
                child: Text(
                  'İlgilenmiyorum',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
          selectedItemBuilder: (BuildContext context) {
            return const [
              Center(child: Text('Okumak İstiyorum', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              Center(child: Text('Okuyorum', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              Center(child: Text('Bitti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              Center(child: Text('İlgilenmiyorum', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ];
          },
        ),
      ),
    );
  }
}
