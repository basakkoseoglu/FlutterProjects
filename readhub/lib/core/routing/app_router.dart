import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/main_navigation_page.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/community/views/community_screen.dart';
import '../../features/profile/views/profile_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/signup_screen.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../features/book_detail/views/book_detail_screen.dart';
import '../../features/book_detail/viewmodels/book_detail_viewmodel.dart';
import '../../features/community/views/book_community_screen.dart';
import '../../features/community/viewmodels/community_viewmodel.dart';
import '../../features/profile/views/notifications_screen.dart';
import '../../features/profile/views/settings_screen.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter {
  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/login',
      refreshListenable: authViewModel,
      redirect: (context, state) {
        final isAuthenticated = authViewModel.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

        if (!isAuthenticated && !isLoggingIn) return '/login';
        if (isAuthenticated && isLoggingIn) return '/home';
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/book/:id',
          builder: (context, state) {
            final bookId = state.pathParameters['id']!;
            return ChangeNotifierProvider(
              create: (_) => BookDetailViewModel(),
              child: BookDetailScreen(bookId: bookId),
            );
          },
          routes: [
            GoRoute(
              path: 'community',
              builder: (context, state) {
                final bookId = state.pathParameters['id']!;
                final bookTitle = state.uri.queryParameters['title'] ?? '';
                return ChangeNotifierProvider(
                  create: (_) => CommunityViewModel(),
                  child: BookCommunityScreen(
                    bookId: bookId,
                    bookTitle: bookTitle,
                  ),
                );
              },
            ),
          ],
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainNavigationPage(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/community',
                  builder: (context, state) => const CommunityScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
