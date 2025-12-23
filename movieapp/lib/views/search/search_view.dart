import 'package:flutter/material.dart';
import 'package:movieapp/viewmodels/favorites_viewmodel.dart';
import 'package:movieapp/viewmodels/search_viewmodel.dart';
import 'package:movieapp/views/movie_detail/movie_detail_view.dart';
import 'package:provider/provider.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Film Ara')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Film adını girin...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    context.read<SearchViewModel>().onSearchQueryChanged(value);
                  },
                ),
              ),
              Expanded(
                child: Consumer<SearchViewModel>(
                  builder: (context, vm, _) {
                    if (vm.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (vm.movies.isEmpty) {
                      return const Center(child: Text('Sonuç bulunamadı.'));
                    }

                    return ListView.builder(
                      itemCount: vm.movies.length,
                      itemBuilder: (context, index) {
                        final movie = vm.movies[index];
                        return ListTile(
                          leading: (movie.posterPath.isNotEmpty)
                              ? Image.network(
                                  'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.movie, size: 50);
                                  },
                                )
                              : const Icon(Icons.movie, size: 50),
                          title: Text(movie.title),
                          subtitle: Text(movie.releaseDate),
                          trailing: Consumer<FavoritesViewmodel>(
                            builder: (context, favVm, _) {
                              final isFav = favVm.isFavorite(movie.id);
                              return IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.red : Colors.grey,
                                ),
                                onPressed: () {
                                  favVm.toggleFavorite(movie);
                                },
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MovieDetailView(movieId: movie.id),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
