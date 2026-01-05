import 'package:flutter/material.dart';
import 'package:workdayapp/core/constants/app_colors.dart';

class TodayStatusCard extends StatelessWidget {
  final String status;

  const TodayStatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final hasRecord = status.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasRecord
              ? const [AppColors.primary, AppColors.primaryLight]
              : const [AppColors.inactiveSoft, AppColors.inactiveSoftLight],
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasRecord ? Icons.work : Icons.event_busy,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bugün', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text(
                hasRecord ? status : 'Henüz kayıt yok',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}