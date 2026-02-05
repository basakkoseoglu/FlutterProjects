import 'package:flutter/material.dart';
import 'package:miniduyuru/viewmodels/auth_viewmodel.dart';
import 'package:miniduyuru/views/admin/adminhome_view.dart';
import 'package:miniduyuru/views/auth/login_view.dart';
import 'package:miniduyuru/views/user/user_notifications_view.dart';
import 'package:provider/provider.dart';

class SplashDecider extends StatelessWidget {
  const SplashDecider({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.userRole == null) {
          return  LoginView();
        }

        if (auth.userRole == 'admin') {
          return const AdminHomeView();
        }

        return const UserNotificationsView();
      },
    );
  }
}