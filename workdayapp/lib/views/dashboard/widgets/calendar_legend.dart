import 'package:flutter/material.dart';
import 'package:workdayapp/core/constants/app_colors.dart';

/// Takvim renk açıklamaları (legend)
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _legendItem('Tam Gün', AppColors.success, Icons.check_circle, isDark),
        _legendItem('Yarım Gün', AppColors.warning, Icons.schedule, isDark),
        _legendItem('İzin', AppColors.danger, Icons.event_busy, isDark),
      ],
    );
  }

  /// Tek bir legend öğesi oluşturur
  Widget _legendItem(String label, Color color, IconData icon, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: Colors.white, size: 12),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
          ),
        ),
      ],
    );
  }
}