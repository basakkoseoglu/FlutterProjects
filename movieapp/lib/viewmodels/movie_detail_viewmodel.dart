import 'package:flutter/material.dart';
import 'package:movieapp/models/movie_model.dart';
import 'package:movieapp/services/movie_api_service.dart';

class MovieDetailViewmodel extends ChangeNotifier{
  final MovieApiService _apiService = MovieApiService();

  Movie? movie;
  bool isLoading=false;
  String? errorMessage;

  Future<void> fetchMovieDetail(int movieId) async {
    isLoading=true;
    notifyListeners();

    try {
      movie=await _apiService.fetchMovieDetail(movieId);
      errorMessage=null;
    } catch (e) {
      errorMessage = 'Film detayı yüklenirken hata oluştu';
    } 
      isLoading=false;
      notifyListeners();
  }
}