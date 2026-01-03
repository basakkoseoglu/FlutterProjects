import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workdayapp/viewmodels/theme_viewmodel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _ProfileHeader(),
          const SizedBox(height: 24),

          const _SectionTitle('Tema'),

          Consumer<ThemeViewModel>(
            builder: (context, themeVM, _) {
              return Column(
                children: [
                  _themeTile(
                    title: 'Sistem Teması',
                    value: ThemeMode.system,
                    groupValue: themeVM.themeMode,
                    onChanged: themeVM.changeTheme,
                  ),
                  _themeTile(
                    title: 'Açık Tema',
                    value: ThemeMode.light,
                    groupValue: themeVM.themeMode,
                    onChanged: themeVM.changeTheme,
                  ),
                  _themeTile(
                    title: 'Koyu Tema',
                    value: ThemeMode.dark,
                    groupValue: themeVM.themeMode,
                    onChanged: themeVM.changeTheme,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          const _SectionTitle('Raporlar'),
          _ProfileTile(
            icon: Icons.picture_as_pdf,
            title: 'PDF Raporları',
            onTap: () {},
          ),

          const SizedBox(height: 24),
          const _SectionTitle('Uygulama'),
          _ProfileTile(
            icon: Icons.info_outline,
            title: 'Hakkında',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: const [
            CircleAvatar(
              radius: 36,
              child: Icon(Icons.person, size: 36),
            ),
            SizedBox(height: 12),
            Text(
              'Kullanıcı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Puantaj Takip Uygulaması',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

Widget _themeTile({
  required String title,
  required ThemeMode value,
  required ThemeMode groupValue,
  required Function(ThemeMode) onChanged,
}) {
  return RadioListTile<ThemeMode>(
    title: Text(title),
    value: value,
    groupValue: groupValue,
    onChanged: (val) {
      if (val != null) {
        onChanged(val);
      }
    },
  );
}
