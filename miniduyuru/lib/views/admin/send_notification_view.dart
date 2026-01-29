import 'package:flutter/material.dart';

class SendNotificationView extends StatelessWidget {
  const SendNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bildirim Gönder')),
      body: Center(child: Text('Admin Bildirim Gönderme Ekranı')),
    );
  }
}