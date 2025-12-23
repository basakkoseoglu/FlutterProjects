import 'package:flutter/material.dart';
import 'package:movieapp/viewmodels/favorites_viewmodel.dart';
import 'package:movieapp/viewmodels/theme_viewmodel.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVm=context.watch<ThemeViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          RadioListTile<ThemeMode>(
            title: const Text('Açık Tema'),
            value: ThemeMode.light,
            groupValue: themeVm.themeMode,
            onChanged: (value) {
                themeVm.setThemeMode(value!);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Koyu Tema'),
            value: ThemeMode.dark,
            groupValue: themeVm.themeMode,
            onChanged: (value) {
                themeVm.setThemeMode(value!);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Sistem Varsayılanı'),
            value: ThemeMode.system,
            groupValue: themeVm.themeMode,
            onChanged: (value) {
                themeVm.setThemeMode(value!);
            },
          ),
          const Divider(height: 32,),
          ListTile(
            leading: const Icon(Icons.delete,color: Colors.red,),
             title: const Text('Favorileri Temizle', style: TextStyle(color: Colors.red),),
            onTap: () {
              showDialog(context: context, builder: (context){
                return AlertDialog(
                  title: const Text('Favoriler Temizlensin mi?'),
                  content: const Text('Tüm favori filmler silinecek. Bu işlem geri alınamaz'),
                  actions: [
                    TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      }, 
                      child: const Text('İptal')),
                    TextButton(
                      onPressed: (){
                        context.read<FavoritesViewmodel>().clearFavorites();
                        Navigator.pop(context);
                      }, 
                      child: const Text('Sil', style: TextStyle(color: Colors.red),)),
                  ],
                );
              });
            },
          ),
        ],
      )
    );
  }
}