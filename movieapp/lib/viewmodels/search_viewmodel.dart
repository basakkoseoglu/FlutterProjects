import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movieapp/models/movie_model.dart';
import 'package:movieapp/services/movie_api_service.dart';

class SearchViewModel extends ChangeNotifier {
final MovieApiService _apiService = MovieApiService();

List<Movie> movies = [];
bool isLoading=false;
bool hasSearched = false;
Timer? _debounce;

void onSearchQueryChanged(String query) {
  _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () {
    searchMovies(query);
  });
}

Future<void> searchMovies(String query) async {
  if (query.isEmpty) {
     hasSearched = false;
      movies = [];
      notifyListeners();
      return;
   }

   hasSearched = true;
  isLoading=true;
  notifyListeners();


    movies=await _apiService.searchMovies(query);
 
 
    isLoading=false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}