import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/theme_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.2,
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSectionContainer(BuildContext context, List<Widget> children, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          _buildSectionHeader('Görünüm', isDark),
          _buildSectionContainer(
            context,
            [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.indigo.shade500 : Colors.amber.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isDark ? LucideIcons.moon : LucideIcons.sun,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  isDark ? 'Koyu Tema' : 'Açık Tema',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    themeViewModel.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
            isDark,
          ),

          _buildSectionHeader('Hesap', isDark),
          _buildSectionContainer(
            context,
            [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.mail, color: Colors.white, size: 20),
                ),
                title: const Text('E-Posta Adresi', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(user?.email ?? 'Yükleniyor...', style: const TextStyle(fontSize: 13)),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.lock, color: Colors.white, size: 20),
                ),
                title: const Text('Şifreyi Değiştir', style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(LucideIcons.chevronRight, size: 20, color: Colors.grey),
                onTap: () async {
                  final email = user?.email;
                  if (email == null || email.isEmpty) return;
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Şifre sıfırlama bağlantısı $email adresine gönderildi.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hata: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
            isDark,
          ),

          _buildSectionHeader('Tercihler', isDark),
          _buildSectionContainer(
            context,
            [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.bellRing, color: Colors.white, size: 20),
                ),
                title: const Text('Anlık Bildirimler', style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text(
                  'Sadece uygulama içi bildirimler aktif.',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Switch(
                  value: themeViewModel.notificationsEnabled,
                  onChanged: (value) {
                    themeViewModel.setNotificationsEnabled(value);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.globe, color: Colors.white, size: 20),
                ),
                title: const Text('Uygulama Dili', style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Text('Türkçe', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ],
            isDark,
          ),

          _buildSectionHeader('Hakkında', isDark),
          _buildSectionContainer(
            context,
            [
              ListTile(
                leading: const Icon(LucideIcons.shieldCheck, color: Colors.grey, size: 24),
                title: const Text('Gizlilik Sözleşmesi', style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(LucideIcons.chevronRight, size: 20, color: Colors.grey),
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(LucideIcons.helpCircle, color: Colors.grey, size: 24),
                title: const Text('Yardım ve Destek', style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(LucideIcons.chevronRight, size: 20, color: Colors.grey),
                onTap: () {},
              ),
            ],
            isDark,
          ),
          
          const SizedBox(height: 32),
          Center(
            child: Text(
              'ReadHub v1.0.0',
              style: TextStyle(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
