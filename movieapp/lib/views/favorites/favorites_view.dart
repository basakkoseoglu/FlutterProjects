import 'package:flutter/material.dart';
import 'package:movieapp/core/constants/api_constants.dart';
import 'package:movieapp/viewmodels/favorites_viewmodel.dart';
import 'package:movieapp/views/movie_detail/movie_detail_view.dart';
import 'package:provider/provider.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favori Filmler'),
        centerTitle: true,
      ),
      body: Consumer<FavoritesViewmodel>(
        builder:(context,vm,_){
          if(vm.favorites.isEmpty){
            return const Center(child: Text('Henüz favori film eklenmedi'));
          }

          return ListView.builder(
            itemCount: vm.favorites.length,
            itemBuilder: (context, index) {
              final movie=vm.favorites[index];
              return ListTile(
                leading: Image.network('${ApiConstants.imageBaseUrl}${movie.posterPath}'),
                title: Text(movie.title),
                subtitle: Text('⭐ ${movie.rating}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    vm.toggleFavorite(movie);
                  },
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder:  (_)=> MovieDetailView(movieId: movie.id)));
                },
              );
            },
          );
        },
      ),
    );
  }
}