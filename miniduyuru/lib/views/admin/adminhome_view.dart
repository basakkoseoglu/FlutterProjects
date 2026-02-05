import 'package:flutter/material.dart';
import 'package:miniduyuru/viewmodels/admin_viewmodel.dart';
import 'package:miniduyuru/viewmodels/auth_viewmodel.dart';
import 'package:miniduyuru/views/admin/add_announcement_sheet.dart';
import 'package:miniduyuru/views/admin/admin_appbar.dart';
import 'package:miniduyuru/views/admin/admin_header.dart';
import 'package:miniduyuru/views/admin/announcements_list.dart';
import 'package:miniduyuru/views/auth/login_view.dart';
import 'package:provider/provider.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  void _showAddAnnouncementSheet(BuildContext context, AdminViewModel vm) {
    vm.clearMessages();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAnnouncementSheet(viewModel: vm),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await _showLogoutDialog(context);

    if (confirm == true && context.mounted) {
      await context.read<AuthViewModel>().logout();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginView()),
        (_) => false,
      );
    }
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Çıkış Yap',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Çıkış yapmak istediğinize emin misiniz?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'İptal',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AdminAppBar(onLogoutPressed: () => _handleLogout(context)),
          body: Column(
            children: [
              AdminHeader(
                onAddPressed: () => _showAddAnnouncementSheet(context, vm),
              ),
              Container(height: 8, color: const Color(0xFFF1F5F9)),
              AnnouncementsList(viewModel: vm),
            ],
          ),
        );
      },
    );
  }
}