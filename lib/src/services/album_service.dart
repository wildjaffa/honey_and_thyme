import 'package:honey_and_thyme/src/models/bool_result.dart';
import 'package:honey_and_thyme/src/services/api_service.dart';

import '../models/add_existing_images_to_album_request.dart';
import '../models/album.dart';

class AlbumService {
  static Future<PaginatedAlbums?> fetchAlbums(
      {int page = 0, int pageSize = 10, String? search}) async {
    try {
      final queryParameters = {
        'pageSize': pageSize.toString(),
        'pageIndex': page.toString(),
        'search': search ?? '',
      };
      final result = await ApiService.getRequest<PaginatedAlbums>(
          'albums/paginated', PaginatedAlbums.fromJson,
          queryParameters: queryParameters);
      return result;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> scanAlbum(Album album) async {
    final result = await ApiService.postRequest(
        'albums/QueueScan', BoolResult.fromJson, album.toJson());
    return result.result!;
  }

  static Future<Album> fetchAlbumById(String albumId, String? password) async {
    Map<String, String>? queryParameters;
    if (password != null) {
      queryParameters = {'password': password};
    }
    final result = await ApiService.getRequest<Album>(
        'albums/$albumId', Album.fromJson,
        queryParameters: queryParameters);
    return result;
  }

  static Future<Album?> fetchAlbumByName(
      String albumName, String? password) async {
    try {
      Map<String, String>? queryParameters;
      if (password != null) {
        queryParameters = {'password': password};
      }
      final result = await ApiService.getRequest<Album>(
          'albums/$albumName', Album.fromJson,
          queryParameters: queryParameters);
      return result;
    } catch (e) {
      return null;
    }
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

  static Future<void> deleteAlbum(String albumId) async {
    await ApiService.deleteRequest('albums/$albumId', BoolResult.fromJson);
  }

  static Future<bool> addImagesToAlbum(
      String albumId, List<String> selectedImages) async {
    final request = AddExistingImagesToAlbumRequest(
      albumId: albumId,
      imageIds: selectedImages,
    );
    final result = await ApiService.postRequest(
        'albums/AddExistingImages', BoolResult.fromJson, request.toJson());
    return result.result!;
  }
}
