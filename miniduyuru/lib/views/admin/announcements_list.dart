import 'package:flutter/material.dart';
import 'package:miniduyuru/viewmodels/admin_viewmodel.dart';
import 'package:miniduyuru/views/admin/announcement_card.dart';
import 'package:miniduyuru/views/admin/empty_announcements_state.dart';

class AnnouncementsList extends StatelessWidget {
  final AdminViewModel viewModel;

  const AnnouncementsList({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
        stream: viewModel.notificationsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const EmptyAnnouncementsState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return AnnouncementCard(
                docId: doc.id,
                title: data['title'] ?? '',
                body: data['body'] ?? '',
                viewModel: viewModel,
              );
            },
          );
        },
      ),
    );
  }
}