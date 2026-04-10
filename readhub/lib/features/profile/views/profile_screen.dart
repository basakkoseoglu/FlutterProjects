import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../viewmodels/profile_viewmodel.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/book_cover_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: const _ProfileScreenContent(),
    );
  }
}

class _ProfileScreenContent extends StatelessWidget {
  const _ProfileScreenContent({Key? key}) : super(key: key);

  Widget _buildAvatar(BuildContext context, String displayName, String photoUrl) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = (displayName.length >= 2)
        ? displayName.substring(0, 2).toUpperCase()
        : (displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : '?');

    if (photoUrl.isNotEmpty && !photoUrl.contains('ui-avatars.com')) {
      return CircleAvatar(
        radius: 46,
        backgroundImage: NetworkImage(photoUrl),
        backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    final palettes = [
      const Color(0xFF6C63FF), const Color(0xFFFF6B6B), const Color(0xFF43AA8B),
      const Color(0xFFFF9F43), const Color(0xFF54A0FF), const Color(0xFFE056FD),
    ];
    final color = palettes.isNotEmpty ? palettes[initials.codeUnitAt(0) % palettes.length] : colorScheme.primary;

    return CircleAvatar(
      radius: 46,
      backgroundColor: color,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, AuthViewModel authVM) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              authVM.logout();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  void _showAvatarSelectionDialog(BuildContext context, AuthViewModel authVM) {
    final avatars = [
      'https://api.dicebear.com/7.x/adventurer-neutral/png?seed=Felix&backgroundColor=b6e3f4',
      'https://api.dicebear.com/7.x/adventurer-neutral/png?seed=Aneka&backgroundColor=c0aede',
      'https://api.dicebear.com/7.x/adventurer-neutral/png?seed=Jack&backgroundColor=ffdfbf',
      'https://api.dicebear.com/7.x/adventurer-neutral/png?seed=Luna&backgroundColor=d1d4f9',
      'https://api.dicebear.com/7.x/adventurer-neutral/png?seed=Oliver&backgroundColor=b6e3f4',
      'https://api.dicebear.com/7.x/adventurer-neutral/png?seed=Zoe&backgroundColor=ffdfbf',
      'https://api.dicebear.com/7.x/adventurer-neutral/png?seed=Sam&backgroundColor=c0aede',
      'https://api.dicebear.com/7.x/adventurer-neutral/png?seed=Mia&backgroundColor=d1d4f9',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Profil Fotoğrafı Seç',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: avatars.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      authVM.updateProfilePhoto(avatars[index]);
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(avatars[index]),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = authViewModel.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    if (viewModel.isLoading || user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Ayarlar',
          ),
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: () => _showLogoutDialog(context, authViewModel),
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _showAvatarSelectionDialog(context, authViewModel),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              child: _buildAvatar(context, user.username, user.profilePhotoUrl),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  LucideIcons.pencil,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.username,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Gün serisi premium rozet tasarımı
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade700, Colors.deepOrange.shade500],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.flame, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${user.streakDays} GÜN SERİSİ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                letterSpacing: 1.2,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Genres (Sevdiği Türler)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: user.favoriteGenres.map((genre) {
                          return Chip(
                            label: Text(genre, style: const TextStyle(fontSize: 12)),
                            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    indicatorColor: colorScheme.primary,
                    labelColor: colorScheme.primary,
                    unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    tabs: const [
                      Tab(text: 'Listeler'),
                      Tab(text: 'İstatistikler'),
                      Tab(text: 'Yorumlar'),
                    ],
                  ),
                  isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              // Listeler Tab
              RefreshIndicator(
                onRefresh: () => viewModel.loadProfileData(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                     _buildListSection(context, 'Okuduklarım', viewModel.readingList),
                     const SizedBox(height: 24),
                     _buildListSection(context, 'Biten Kitaplar', viewModel.finishedList),
                     const SizedBox(height: 24),
                     _buildListSection(context, 'Okumak İstediklerim', viewModel.wantToReadList),
                     if (viewModel.readingList.isEmpty && viewModel.finishedList.isEmpty && viewModel.wantToReadList.isEmpty)
                       Padding(
                         padding: const EdgeInsets.only(top: 40.0),
                         child: Center(
                           child: Column(
                             children: [
                               Icon(LucideIcons.library, size: 60, color: Colors.grey.shade400),
                               const SizedBox(height: 16),
                               Text(
                                 'Listelerinde hiç kitap yok.',
                                 style: TextStyle(color: Colors.grey.shade500),
                               ),
                             ],
                           ),
                         ),
                       ),
                  ],
                ),
              ),
              // İstatistikler Tab
              ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildLibraryGraphic(context, viewModel),
                  _buildStatCard(
                    context,
                    icon: LucideIcons.checkSquare,
                    title: 'Biten Kitap Sayısı',
                    value: '${viewModel.totalFinished}',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    context,
                    icon: LucideIcons.bookOpen,
                    title: 'Okunan Toplam Sayfa',
                    value: '${viewModel.totalPagesRead}',
                    color: Colors.blue,
                  ),
                ],
              ),
              // Yorumlar Tab
              viewModel.userComments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.messageSquare, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz yorum yapmadın.',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: viewModel.userComments.length,
                      itemBuilder: (context, index) {
                        final comment = viewModel.userComments[index];
                        final bookTitle = (comment['bookTitle'] as String?) ?? 'Bilinmeyen Kitap';
                        final text = (comment['text'] as String?) ?? '';
                        final stamp = comment['createdAt'];
                        String dateStr = '';
                        if (stamp != null) {
                          try {
                            final dt = (stamp as dynamic).toDate() as DateTime;
                            dateStr = '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
                          } catch (_) {}
                        }
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                          ),
                          child: InkWell(
                            onTap: () {
                              final bookId = comment['bookId'] as String?;
                              if (bookId != null) {
                                context.push('/book/$bookId');
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          bookTitle,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        dateStr,
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    text,
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required IconData icon, required String title, required String value, required Color color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
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
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            radius: 24,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                )),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLibraryGraphic(BuildContext context, ProfileViewModel viewModel) {
    final finished = viewModel.finishedList.length;
    final reading = viewModel.readingList.length;
    final wantToRead = viewModel.wantToReadList.length;
    final total = finished + reading + wantToRead;
    
    if (total == 0) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kitaplık Durumu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                if (finished > 0) Expanded(flex: finished, child: Container(height: 12, color: Colors.green)),
                if (reading > 0) Expanded(flex: reading, child: Container(height: 12, color: Colors.blue)),
                if (wantToRead > 0) Expanded(flex: wantToRead, child: Container(height: 12, color: Colors.orange)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem('Biten', Colors.green, finished),
              _buildLegendItem('Okunuyor', Colors.blue, reading),
              _buildLegendItem('İstiyorum', Colors.orange, wantToRead),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label ($count)', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildListSection(BuildContext context, String title, List books) {
    if (books.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${books.length}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () => context.push('/book/${book.id}'),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BookCoverWidget(
                      coverUrl: book.coverUrl,
                      width: 105,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this._color);

  final TabBar _tabBar;
  final Color _color;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _color,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
