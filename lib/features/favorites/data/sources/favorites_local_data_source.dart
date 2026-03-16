import 'package:hive_flutter/hive_flutter.dart';
import '../../../home/data/models/song_model.dart';
import 'dart:convert';

abstract class FavoritesLocalDataSource {
  Future<List<SongModel>> getCachedFavorites();
  Future<void> cacheFavorites(List<SongModel> favorites);
  Future<void> addFavorite(SongModel song);
  Future<void> removeFavorite(String songId);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  static const _boxName = 'favorites';
  
  Box<dynamic> get _box => Hive.box(_boxName);

  @override
  Future<List<SongModel>> getCachedFavorites() async {
    try {
      final jsonListString = _box.get('cached_favorites');
      if (jsonListString != null) {
        final List<dynamic> decoded = jsonDecode(jsonListString);
        return decoded.map((e) => SongModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Ignorar errores de caché
    }
    return [];
  }

  @override
  Future<void> cacheFavorites(List<SongModel> favorites) async {
    final list = favorites.map((e) => e.toJson()).toList();
    await _box.put('cached_favorites', jsonEncode(list));
  }

  @override
  Future<void> addFavorite(SongModel song) async {
    final current = await getCachedFavorites();
    if (!current.any((e) => e.id == song.id)) {
      current.add(song);
      await cacheFavorites(current);
    }
  }

  @override
  Future<void> removeFavorite(String songId) async {
    final current = await getCachedFavorites();
    current.removeWhere((e) => e.id == songId);
    await cacheFavorites(current);
  }
}
