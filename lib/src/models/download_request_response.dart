class DownloadRequestResponse {
  String? downloadUrl;

  DownloadRequestResponse({this.downloadUrl});

  DownloadRequestResponse.fromJson(dynamic json) {
    downloadUrl = json['DownloadUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DownloadUrl'] = downloadUrl;
    return data;
  }
}
