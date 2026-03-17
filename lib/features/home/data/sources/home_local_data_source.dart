import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/album_model.dart';
import '../models/playlist_model.dart';

abstract class HomeLocalDataSource {
  Future<List<AlbumModel>> getCachedAlbums();
  Future<void> cacheAlbums(List<AlbumModel> albums);
  Future<List<PlaylistModel>> getCachedPlaylists();
  Future<void> cachePlaylists(List<PlaylistModel> playlists);
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  static const _homeBoxName = 'home_cache';
  
  Box<dynamic> get _box => Hive.box(_homeBoxName);

  @override
  Future<List<AlbumModel>> getCachedAlbums() async {
    try {
      final data = _box.get('albums');
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        return decoded.map((e) => AlbumModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> cacheAlbums(List<AlbumModel> albums) async {
    final encoded = jsonEncode(albums.map((e) => e.toJson()).toList());
    await _box.put('albums', encoded);
  }

  @override
  Future<List<PlaylistModel>> getCachedPlaylists() async {
    try {
      final data = _box.get('playlists');
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        return decoded.map((e) => PlaylistModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> cachePlaylists(List<PlaylistModel> playlists) async {
    final encoded = jsonEncode(playlists.map((e) => e.toJson()).toList());
    await _box.put('playlists', encoded);
  }
}
