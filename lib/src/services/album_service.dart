import 'package:honey_and_thyme/src/models/bool_result.dart';
import 'package:honey_and_thyme/src/services/api_service.dart';

import '../models/album.dart';

class AlbumService {
  static Future<List<Album>> fetchAlbums() async {
    final result =
        await ApiService.getRequest<Albums>('albums/all', Albums.fromJson);
    return result.values as List<Album>;
  }

  static Future<Album> fetchAlbumById(int albumId, String? password) async {
    Map<String, String>? queryParameters;
    if (password != null) {
      queryParameters = {'password': password};
    }
    final result = await ApiService.getRequest<Album>(
        'albums/$albumId', Album.fromJson,
        queryParameters: queryParameters);
    return result;
  }

  static Future<Album> fetchAlbumByName(
      String albumName, String? password) async {
    Map<String, String>? queryParameters;
    if (password != null) {
      queryParameters = {'password': password};
    }
    final result = await ApiService.getRequest<Album>(
        'albums/$albumName', Album.fromJson,
        queryParameters: queryParameters);
    return result;
  }

  static Future<Album> createAlbum(Album album) async {
    final result = await ApiService.postRequest<Album>(
        'albums/create', Album.fromJson, album.toJson());
    return result;
  }

  static Future<Album> updateAlbum(Album album) async {
    final result = await ApiService.postRequest<Album>(
        'albums/update', Album.fromJson, album.toJson());
    return result;
  }

  static Future<Album> unlockAlbum(Album album) async {
    final result = await ApiService.postRequest<Album>(
        'albums/unlock', Album.fromJson, album.toJson());
    return result;
  }

  static Future<void> deleteAlbum(int albumId) async {
    await ApiService.deleteRequest('albums/$albumId', BoolResult.fromJson);
  }
}
