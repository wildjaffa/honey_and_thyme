import 'dart:typed_data';

import 'package:honey_and_thyme/src/models/bool_result.dart';
import 'package:honey_and_thyme/src/models/download_request_config.dart';
import 'package:honey_and_thyme/src/models/download_request_response.dart';
import 'package:honey_and_thyme/src/models/enums/download_image_type.dart';
import 'package:http_parser/http_parser.dart';

import '../models/download_request.dart';
import '../models/enums/download_image_sizes.dart';
import '../models/enums/image_sizes.dart';
import '../models/form_file.dart';
import '../models/image.dart';
import 'api_service.dart';

class ImageService {
  static Future<ImageData> uploadImage(
      int albumId, Uint8List image, String fileName) async {
    final newImage = await ApiService.multiPartFormRequest<ImagesData>(
        'images/upload', ImagesData.fromJson, {
      "AlbumId": albumId.toString(),
    }, [
      FormFile(
        contentType: MediaType("image", "png"),
        fileBytes: image,
        fileName: fileName,
        formFieldName: 'ImageFiles',
      ),
    ]);
    return newImage.values!.first!;
  }

  static Future<ImageData> getImageData(int imageId) async {
    final image = await ApiService.getRequest<ImageData>(
        'images/imageData/$imageId', ImageData.fromJson);
    return image;
  }

  static String getImageUrl(int imageId, ImageSizes size, String? password) {
    final baseUrl = ApiService.url;
    final sizeId = size.index;
    final uri = ApiService.getUri(baseUrl, 'thumb/$sizeId/$imageId', {
      if (password != null) 'password': password,
    });
    return uri.toString();
  }

  static Future<BoolResult> deleteImage(int imageId) async {
    final result =
        await ApiService.deleteRequest('images/$imageId', BoolResult.fromJson);
    return result;
  }

  static Future<Uri> getImageDownloadUrl(List<int> imageIds,
      DownloadImageSizes downloadSize, String? password) async {
    final DownloadRequestConfig config = DownloadRequestConfig(
      exportConfigId: 0,
      keepFolders: false,
      name: 'Download',
      watermarkText: null,
      size: downloadSize.index,
      type: DownloadImageType.download.index,
    );
    final downloadImageRequest = DownloadImageRequest(
      imageIds: imageIds,
      config: config,
      password: password,
    );
    final result = await ApiService.postRequest<DownloadRequestResponse>(
        'api/download/images',
        DownloadRequestResponse.fromJson,
        downloadImageRequest.toJson());
    return ApiService.getUri(ApiService.url, result.downloadUrl!);
  }
}
