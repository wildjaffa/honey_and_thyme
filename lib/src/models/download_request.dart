import 'download_request_config.dart';

class DownloadImageRequest {
  List<String?>? imageIds;
  DownloadRequestConfig? config;
  String? password;

  DownloadImageRequest({this.imageIds, this.config, this.password});

  DownloadImageRequest.fromJson(dynamic json) {
    if (json['ImageIds'] != null) {
      imageIds = <String>[];
      json['ImageIds'].forEach((v) {
        imageIds!.add(v);
      });
    }
    password = json['password'];
    config = json['Config'] != null
        ? DownloadRequestConfig?.fromJson(json['Config'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ImageIds'] = imageIds?.map((v) => v).toList();
    data['Config'] = config!.toJson();
    data['password'] = password;
    return data;
  }
}
