class DownloadRequestResponse {
  bool? startedSuccessfully;

  DownloadRequestResponse({this.startedSuccessfully});

  DownloadRequestResponse.fromJson(dynamic json) {
    startedSuccessfully = json['StartedSuccessfully'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['StartedSuccessfully'] = startedSuccessfully;
    return data;
  }
}
