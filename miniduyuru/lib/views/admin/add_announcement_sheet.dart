import 'package:flutter/material.dart';
import 'package:miniduyuru/viewmodels/admin_viewmodel.dart';
import 'package:miniduyuru/views/admin/custom_text_field.dart';
import 'package:provider/provider.dart';

class AddAnnouncementSheet extends StatelessWidget {
  final AdminViewModel viewModel;

  const AddAnnouncementSheet({
    super.key,
    required this.viewModel,
  });

  Future<void> _handleSubmit(BuildContext context, AdminViewModel vm) async {
    final success = await vm.sendNotification();

    if (!context.mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.successMessage!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF10B981),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFEF4444),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandleBar(),
          _buildHeader(context),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          _buildForm(),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE6FAF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.add_circle_outline,
                color: Color(0xFF10B981),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yeni Duyuru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tüm kullanıcılara bildirim gönder',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: viewModel.titleController,
              label: 'Başlık',
              icon: Icons.title_outlined,
              maxLines: 1,
              hint: 'Örn: Önemli Duyuru',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: viewModel.bodyController,
              label: 'İçerik',
              icon: Icons.notes_outlined,
              maxLines: 5,
              hint: 'Duyuru içeriğini buraya yazın...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: Consumer<AdminViewModel>(
            builder: (context, vm, _) {
              return vm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF10B981)),
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.send_outlined, size: 20),
                      label: const Text(
                        'Duyuruyu Gönder',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => _handleSubmit(context, vm),
                    );
            },
          ),
        ),
      ),
    );
  }
}