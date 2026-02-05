import 'package:flutter/material.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogoutPressed;

  const AdminAppBar({
    super.key,
    required this.onLogoutPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.notifications_active,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'MiniDuyuru',
            style: TextStyle(
              fontSize: 18,
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
            onPressed: onLogoutPressed,
          ),
        ),
      ],
    );
  }
}