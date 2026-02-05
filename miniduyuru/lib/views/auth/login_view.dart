import 'package:flutter/material.dart';
import 'package:miniduyuru/viewmodels/auth_viewmodel.dart';
import 'package:miniduyuru/views/admin/adminhome_view.dart';
import 'package:miniduyuru/views/user/user_notifications_view.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.10),

                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.notifications_outlined,
                            size: 34,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Center(
                      child: Text(
                        'Hoş Geldiniz',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Hesabınıza giriş yapın',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),

                    _buildTextField(
                      controller: emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      obscure: false,
                    ),

                    const SizedBox(height: 14),

                    _buildTextField(
                      controller: passwordController,
                      label: 'Şifre',
                      icon: Icons.lock_outlined,
                      obscure: true,
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: vm.isLoading
                          ? Center(
                              child: const CircularProgressIndicator(
                                color: Color(0xFF3B82F6),
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                await vm.login(
                                  emailController.text,
                                  passwordController.text,
                                );

                                if (vm.userRole == 'admin') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AdminHomeView(),
                                    ),
                                  );
                                } else if (vm.userRole == 'user') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const UserNotificationsView(),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(
                                      content:
                                          Text('Kullanıcı rolü belirlenemedi'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),

                    if (vm.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Color(0xFFEF4444), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                vm.errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF3B82F6), width: 1.8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}