import 'package:flutter/material.dart';

class NotificationListView extends StatelessWidget {
  const NotificationListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bildirimler')),
      body: Center(child: Text('Kullanıcı Bildirim Listesi Ekranı')),
    );
  }
}