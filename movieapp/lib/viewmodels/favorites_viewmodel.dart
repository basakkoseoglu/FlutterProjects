import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movieapp/models/movie_model.dart';

class FavoritesViewmodel extends ChangeNotifier {
  static const String _key='favorite_movies';

  List<Movie>favorites=[];

  //uyg açılınca çalışacak
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? data = prefs.getStringList(_key);
    if (data != null) {
      favorites = data.map((e) {
        final Map<String, dynamic> json = jsonDecode(e);
        return Movie.fromJson(json);
      }).toList();
    }
    notifyListeners();
  }

  bool isFavorite(int movieId){
    return favorites.any((m) => m.id==movieId);
  }

  Future<void> toggleFavorite(Movie movie) async {
  final prefs = await SharedPreferences.getInstance();
  if (isFavorite(movie.id)) {
    favorites.removeWhere((m) => m.id == movie.id);
  } else {
    favorites.add(movie);
  }

  final data = favorites.map((m) => jsonEncode(m.toJson())).toList();
  await prefs.setStringList(_key, data);
  notifyListeners();
}

Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    favorites.clear();
    await prefs.remove(_key);
    notifyListeners();
  }
}