import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock active discussions feed
    final activeDiscussions = [
      {
        'bookId': '1', // The Midnight Library
        'bookTitle': 'Gece Yarısı Kütüphanesi',
        'bookCover': 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=400&auto=format&fit=crop',
        'recentComment': '5. bölüme gelen var mı? Nora\'nın seçimleri yürek parçalayıcı.',
        'user': 'Ali',
        'timeAgo': '2 saat önce',
        'replyCount': 12,
      },
      {
        'bookId': '2', // Dune
        'bookTitle': 'Dune',
        'bookCover': 'https://images.unsplash.com/photo-1628126235206-5260b9ea6441?q=80&w=400&auto=format&fit=crop',
        'recentComment': 'Paul\'un çöldeki vizyonu tüm serinin tonunu gerçekten belirliyor.',
        'user': 'Bora',
        'timeAgo': '5 saat önce',
        'replyCount': 45,
      },
      {
        'bookId': '4', // Atomic Habits
        'bookTitle': 'Atomik Alışkanlıklar',
        'bookCover': 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?q=80&w=400&auto=format&fit=crop',
        'recentComment': 'Alışkanlıklarımı 2 hafta önce takip etmeye başladım ve %1 kuralı gerçekten işe yarıyor!',
        'user': 'Can',
        'timeAgo': '1 gün önce',
        'replyCount': 8,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Topluluk Akışı', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () {
              context.push('/notifications');
            },
          ),
        ],
      ),
      body: activeDiscussions.isEmpty
          ? ShimmerLoading(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) => const ListTileShimmer(),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: activeDiscussions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
          final discussion = activeDiscussions[index];
          return GestureDetector(
            onTap: () {
              final title = discussion['bookTitle'] as String;
              context.push('/book/${discussion['bookId']}/community?title=${Uri.encodeComponent(title)}');
            },
            child: Container(
              padding: const EdgeInsets.all(16),
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
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          discussion['bookCover'] as String,
                          width: 40,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tartışma:',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            Text(
                              discussion['bookTitle'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(LucideIcons.chevronRight, size: 20, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          (discussion['user'] as String)[0],
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        discussion['user'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Spacer(),
                      Text(
                        discussion['timeAgo'] as String,
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"${discussion['recentComment']}"',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(LucideIcons.messageCircle, size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${discussion['replyCount']} yanıt',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
