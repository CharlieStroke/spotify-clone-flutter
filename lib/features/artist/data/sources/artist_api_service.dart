import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/artist_model.dart';
import '../../../home/data/models/album_model.dart';
import '../../../home/data/models/song_model.dart';
import 'dart:io';

abstract class ArtistApiService {
  Future<ArtistModel?> getMyArtistProfile();
  Future<ArtistModel> createArtist({
    required String stageName,
    required String bio,
    required File image,
  });
  
  // Albums
  Future<List<AlbumModel>> getMyAlbums();
  Future<AlbumModel> createAlbum({
    required String title,
    required File cover,
  });
  
  // Songs
  Future<SongModel> uploadSong({
    required String title,
    required int albumId,
    required File audio,
    required File cover,
  });
}

class ArtistApiServiceImpl implements ArtistApiService {
  final ApiClient _apiClient;

  ArtistApiServiceImpl(this._apiClient);

  @override
  Future<ArtistModel?> getMyArtistProfile() async {
    try {
      final response = await _apiClient.dio.get('/artists/me');
      if (response.data != null && response.data['success'] == true) {
        return ArtistModel.fromJson(response.data['artist']);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // No es artista
      }
      rethrow;
    }
  }

  @override
  Future<ArtistModel> createArtist({
    required String stageName,
    required String bio,
    required File image,
  }) async {
    final formData = FormData.fromMap({
      'stage_name': stageName,
      'bio': bio,
      'image': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
    });

    final response = await _apiClient.dio.post(
      '/artists/create',
      data: formData,
    );

    if (response.data != null && response.data['success'] == true) {
      return ArtistModel.fromJson(response.data['artist']);
    } else {
      throw Exception(response.data['message'] ?? 'Error al crear perfil de artista');
    }
  }

  @override
  Future<List<AlbumModel>> getMyAlbums() async {
    final response = await _apiClient.dio.get('/albums');
    if (response.data != null && response.data['success'] == true) {
      final List albums = response.data['albums'];
      return albums.map((e) => AlbumModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<AlbumModel> createAlbum({
    required String title,
    required File cover,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'cover': await MultipartFile.fromFile(
        cover.path,
        filename: cover.path.split('/').last,
      ),
    });

    final response = await _apiClient.dio.post(
      '/albums/create',
      data: formData,
    );

    if (response.data != null && response.data['success'] == true) {
      return AlbumModel.fromJson(response.data['album']);
    } else {
      throw Exception(response.data['message'] ?? 'Error al crear álbum');
    }
  }

  @override
  Future<SongModel> uploadSong({
    required String title,
    required int albumId,
    required File audio,
    required File cover,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'albumId': albumId,
      'audio': await MultipartFile.fromFile(
        audio.path,
        filename: audio.path.split('/').last,
      ),
      'cover': await MultipartFile.fromFile(
        cover.path,
        filename: cover.path.split('/').last,
      ),
    });

    final response = await _apiClient.dio.post(
      '/songs/addsong',
      data: formData,
    );

    if (response.data != null && response.data['success'] == true) {
      // El backend devuelve { success, message, song }
      // El modelo SongModel.fromJson espera el objeto canción
      return SongModel.fromJson(response.data['song'] ?? {});
    } else {
      throw Exception(response.data['message'] ?? 'Error al subir canción');
    }
  }
}
