import 'package:flutter/material.dart';

class EmptyAnnouncementsState extends StatelessWidget {
  const EmptyAnnouncementsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.campaign_outlined,
                color: Color(0xFF94A3B8),
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz duyuru yok',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'İlk duyuruyu göndermek için yukarıdaki\nbutona tıklayın',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}