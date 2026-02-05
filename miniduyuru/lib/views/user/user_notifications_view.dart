import 'package:flutter/material.dart';
import 'package:miniduyuru/viewmodels/auth_viewmodel.dart';
import 'package:miniduyuru/viewmodels/user_viewmodel.dart';
import 'package:miniduyuru/views/auth/login_view.dart';
import 'package:provider/provider.dart';

class UserNotificationsView extends StatelessWidget {
  const UserNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Center(
                child: Icon(
                  Icons.notifications_outlined,
                  size: 18,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'MiniDuyuru',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.logout_outlined, color: Color(0xFF64748B)),
              onPressed: () async {
                await context.read<AuthViewModel>().logout();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginView()),
                  (_) => false,
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer<UserViewModel>(
        builder: (context, vm, _) {
          final stream = vm.notificationsStream;

          if (stream == null) {
            return const Center(
              child: Text(
                'Lütfen giriş yapın',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            );
          }

          return StreamBuilder(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3B82F6),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.notifications_off_outlined,
                            color: Color(0xFF94A3B8),
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Henüz duyuru yok',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Yeni duyurular burada görünecek',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.notifications_outlined,
                              color: Color(0xFF3B82F6),
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['title'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                data['body'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}