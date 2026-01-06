import 'package:flutter/material.dart';
import 'package:workdayapp/core/constants/app_colors.dart';
import 'package:workdayapp/viewmodels/theme/theme_viewmodel.dart';

void showThemeDialog(BuildContext context, ThemeViewModel themeVM) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.palette_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tema Seçimi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _themeOption(
              context: context,
              icon: Icons.brightness_auto,
              title: 'Sistem Teması',
              subtitle: 'Cihazınızın temasını takip eder',
              isSelected: themeVM.themeMode == ThemeMode.system,
              isDark: isDark,
              onTap: () {
                themeVM.changeTheme(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _themeOption(
              context: context,
              icon: Icons.light_mode,
              title: 'Açık Tema',
              subtitle: 'Aydınlık görünüm',
              isSelected: themeVM.themeMode == ThemeMode.light,
              isDark: isDark,
              onTap: () {
                themeVM.changeTheme(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _themeOption(
              context: context,
              icon: Icons.dark_mode,
              title: 'Koyu Tema',
              subtitle: 'Karanlık görünüm',
              isSelected: themeVM.themeMode == ThemeMode.dark,
              isDark: isDark,
              onTap: () {
                themeVM.changeTheme(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _themeOption({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required bool isSelected,
  required bool isDark,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.08)
            : (isDark ? Colors.grey.shade800 : Colors.grey.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withOpacity(0.3)
              : (isDark ? Colors.grey.shade700 : Colors.grey.withOpacity(0.2)),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_circle,
              color: AppColors.primary,
              size: 22,
            ),
        ],
      ),
    ),
  );
}