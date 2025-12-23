import 'package:flutter/material.dart';
import 'package:movieapp/viewmodels/favorites_viewmodel.dart';
import 'package:movieapp/viewmodels/movie_list_viewmodel.dart';
import 'package:movieapp/viewmodels/theme_viewmodel.dart';
import 'package:movieapp/views/movie_list/movie_list_view.dart';
import 'package:provider/provider.dart';

void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(providers:
    [
    ChangeNotifierProvider(
      create: (_)=> MovieListViewmodel()..fetchPopularMovies(),
    ),
    ChangeNotifierProvider(create: (_)=>FavoritesViewmodel()..loadFavorites(),
    ),
    ChangeNotifierProvider(create: (_)=>ThemeViewModel(),)
    ], 
    child: const MyApp()
    ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeVm, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Popüler Filmler',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeVm.themeMode,
          home: const MovieListView(),
        );
      },
    );
  }
}

