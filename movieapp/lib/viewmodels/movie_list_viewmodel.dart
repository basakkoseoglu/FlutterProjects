import 'package:flutter/material.dart';
import 'package:movieapp/models/movie_model.dart';
import 'package:movieapp/services/movie_api_service.dart';

class MovieListViewmodel extends ChangeNotifier {
  final MovieApiService _apiService = MovieApiService();

  List<Movie> movies = [];

  bool isLoading=false;
  String? errorMessage;

  int  _currentPage=1;
  bool hasMore=true;

  //popüler filmleri getir
  Future<void> fetchPopularMovies({bool loadMore = false}) async {
    if(isLoading) return;

    isLoading=true;
    notifyListeners();

    try {
      if(loadMore){
        _currentPage++;
      }else{
        _currentPage=1;
        movies.clear();
      }

      final newMovies=await _apiService.fetchPopularMovies(page: _currentPage);
      if(newMovies.isEmpty){
        hasMore=false;
      }else{
        movies.addAll(newMovies);
      }
      errorMessage=null;
    } catch (e) {
      errorMessage = 'Filmler yüklenirken hata oluştu';
    } 
      isLoading=false;
      notifyListeners();
  }
}