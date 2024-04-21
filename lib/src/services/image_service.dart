import 'dart:typed_data';

import 'package:honey_and_thyme/src/models/bool_result.dart';
import 'package:http_parser/http_parser.dart';

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

  static String getImageUrl(int imageId, ImageSizes size) {
    const baseUrl = ApiService.url;
    final size = ImageSizes.medium.index;
    final uri = ApiService.getUri(baseUrl, 'thumb/$size/$imageId');
    return uri.toString();
  }

  static Future<BoolResult> deleteImage(int imageId) async {
    final result =
        await ApiService.deleteRequest('images/$imageId', BoolResult.fromJson);
    return result;
  }
}
