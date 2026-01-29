import 'package:flutter/material.dart';
import 'package:miniduyuru/viewmodels/auth_viewmodel.dart';
import 'package:miniduyuru/views/admin/send_notification_view.dart';
import 'package:miniduyuru/views/user/notification_list_view.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Consumer<AuthViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(title: Text('Giriş Yap')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Şifre'),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  if (vm.isLoading)
                    CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: () async {
                        await vm.login(
                          emailController.text,
                          passwordController.text,
                        );
                        if (vm.userRole == 'admin') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SendNotificationView(),
                            ),
                          );
                        } else if (vm.userRole == 'user') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationListView(),
                            ),
                          );
                        }
                      },
                      child: const Text('Giriş Yap'),
                    ),

                  if (vm.errorMessage != null)
                    Text(
                      vm.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
