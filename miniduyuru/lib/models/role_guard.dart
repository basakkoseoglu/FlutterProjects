import 'package:flutter/material.dart';
import 'package:miniduyuru/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class RoleGuard extends StatelessWidget {
  final String requiredRole;
  final Widget child;

  const RoleGuard({
    super.key,
    required this.requiredRole,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.userRole != requiredRole) {
          return const Scaffold(
            body: Center(child: Text('Yetkin yok')),
          );
        }

        return child;
      },
    );
  }
}
