import 'package:flutter/material.dart';

class AdminHeader extends StatelessWidget {
  final VoidCallback onAddPressed;

  const AdminHeader({
    super.key,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Duyurular',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gönderilen tüm duyuruları görüntüle',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline, size: 22),
              label: const Text(
                'Yeni Duyuru Ekle',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              onPressed: onAddPressed,
            ),
          ),
        ],
      ),
    );
  }
}