import 'package:flutter/material.dart';
import 'package:movieapp/core/constants/api_constants.dart';
import 'package:movieapp/viewmodels/favorites_viewmodel.dart';
import 'package:movieapp/viewmodels/movie_detail_viewmodel.dart';
import 'package:provider/provider.dart';

class MovieDetailView extends StatelessWidget {
  final int movieId;
  const MovieDetailView({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MovieDetailViewmodel()..fetchMovieDetail(movieId),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Consumer2<MovieDetailViewmodel, FavoritesViewmodel>(
              builder: (context, detailVm, favVm, _) {
                final movie = detailVm.movie;
                if (movie == null) {
                  return const SizedBox();
                }
                final isFav = favVm.isFavorite(movie.id);
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.white,
                  ),
                  onPressed: () {
                    favVm.toggleFavorite(movie);
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<MovieDetailViewmodel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.errorMessage != null) {
              return Center(child: Text(vm.errorMessage!));
            }

            final movie = vm.movie;
            if (movie == null) return const SizedBox();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resim kontrolü
                  (movie.posterPath.isNotEmpty)
                      ? Image.network(
                          '${ApiConstants.imageBaseUrl}${movie.posterPath}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 400,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 400,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.movie,
                                size: 100,
                                color: Colors.grey,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: double.infinity,
                              height: 400,
                              color: Colors.grey[300],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          width: double.infinity,
                          height: 400,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.movie,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text('⭐ ${movie.rating.toStringAsFixed(1)}'),
                        const SizedBox(height: 8),
                        if (movie.releaseDate.isNotEmpty)
                          Text('Yayın tarihi: ${movie.releaseDate}'),
                        const SizedBox(height: 16),
                        Text(movie.overview),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
