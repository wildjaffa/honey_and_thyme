class CaptureOrderResponse {
  bool? wasSuccessful;

  CaptureOrderResponse({this.wasSuccessful});

  CaptureOrderResponse.fromJson(dynamic json) {
    wasSuccessful = json['WasSuccessful'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['WasSuccessful'] = wasSuccessful;
    return data;
  }
}
