import 'download_request_config.dart';

class DownloadImageRequest {
  List<String?>? imageIds;
  DownloadRequestConfig? config;
  String? password;
  String? connectionId;

  DownloadImageRequest(
      {this.imageIds, this.config, this.password, this.connectionId});

  DownloadImageRequest.fromJson(dynamic json) {
    if (json['imageIds'] != null) {
      imageIds = <String>[];
      json['imageIds'].forEach((v) {
        imageIds!.add(v);
      });
    }
    password = json['password'];
    connectionId = json['connectionId'];
    config = json['config'] != null
        ? DownloadRequestConfig?.fromJson(json['config'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['imageIds'] = imageIds?.map((v) => v).toList();
    data['config'] = config!.toJson();
    data['password'] = password;
    data['connectionId'] = connectionId;
    return data;
  }
}
