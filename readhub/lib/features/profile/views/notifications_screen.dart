import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../viewmodels/notification_viewmodel.dart';
import '../models/notification_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (viewModel.notifications.any((n) => n.isUnread))
            TextButton(
              onPressed: () => viewModel.markAllAsRead(),
              child: const Text('Tümünü Oku'),
            ),
        ],
      ),
      body: viewModel.isLoading
          ? ShimmerLoading(
              child: ListView.separated(
                itemCount: 8,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) => const ListTileShimmer(),
              ),
            )
          : viewModel.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.bellOff, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz bildirim yok',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: viewModel.notifications.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notification = viewModel.notifications[index];
                    final isUnread = notification.isUnread;
                    
                    IconData icon;
                    Color iconColor;
                    if (notification.type == NotificationType.reply) {
                      icon = LucideIcons.messageCircle;
                      iconColor = Theme.of(context).colorScheme.primary;
                    } else if (notification.type == NotificationType.like) {
                      icon = LucideIcons.heart;
                      iconColor = Colors.red;
                    } else {
                      icon = LucideIcons.info;
                      iconColor = Colors.blue;
                    }

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      tileColor: isUnread 
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05) 
                          : Colors.transparent,
                      leading: CircleAvatar(
                        backgroundColor: iconColor.withValues(alpha: 0.1),
                        child: Icon(icon, color: iconColor, size: 20),
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          notification.subtitle,
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(notification.createdAt),
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontSize: 12,
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(height: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ]
                        ],
                      ),
                      onTap: () {
                        if (isUnread) {
                          viewModel.markAsRead(notification.id);
                        }
                        if (notification.bookId != null) {
                           context.push('/book/${notification.bookId}/community');
                        }
                      },
                    );
                  },
                ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Şimdi';
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk önce';
    if (diff.inHours < 24) return '${diff.inHours}s önce';
    if (diff.inDays < 7) return '${diff.inDays}g önce';
    return '${time.day}.${time.month}.${time.year}';
  }
}
