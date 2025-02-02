class DownloadRequestResponse {
  bool? startedSuccessfully;

  DownloadRequestResponse({this.startedSuccessfully});

  DownloadRequestResponse.fromJson(dynamic json) {
    startedSuccessfully = json['startedSuccessfully'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['startedSuccessfully'] = startedSuccessfully;
    return data;
  }
}
