import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../home/data/models/album_model.dart';
import '../../../home/data/models/playlist_model.dart';

abstract class LibraryLocalDataSource {
  Future<Map<String, List<dynamic>>> getCachedLibrary();
  Future<void> cacheLibrary(Map<String, List<dynamic>> library);
}

class LibraryLocalDataSourceImpl implements LibraryLocalDataSource {
  static const _libraryBoxName = 'library_cache';
  
  Box<dynamic> get _box => Hive.box(_libraryBoxName);

  @override
  Future<Map<String, List<dynamic>>> getCachedLibrary() async {
    try {
      final playlistsData = _box.get('playlists');
      final albumsData = _box.get('albums');
      
      List<PlaylistModel> playlists = [];
      List<AlbumModel> albums = [];

      if (playlistsData != null) {
        final List<dynamic> decoded = jsonDecode(playlistsData);
        playlists = decoded.map((e) => PlaylistModel.fromJson(e as Map<String, dynamic>)).toList();
      }

      if (albumsData != null) {
        final List<dynamic> decoded = jsonDecode(albumsData);
        albums = decoded.map((e) => AlbumModel.fromJson(e as Map<String, dynamic>)).toList();
      }

      return {
        'playlists': playlists,
        'albums': albums,
      };
    } catch (_) {}
    return {
      'playlists': [],
      'albums': [],
    };
  }

  @override
  Future<void> cacheLibrary(Map<String, List<dynamic>> library) async {
    try {
      if (library['playlists'] != null) {
        final playlists = library['playlists'] as List<dynamic>;
        final encoded = jsonEncode(playlists.map((e) => (e as PlaylistModel).toJson()).toList());
        await _box.put('playlists', encoded);
      }
      if (library['albums'] != null) {
        final albums = library['albums'] as List<dynamic>;
        final encoded = jsonEncode(albums.map((e) => (e as AlbumModel).toJson()).toList());
        await _box.put('albums', encoded);
      }
    } catch (_) {}
  }
}
