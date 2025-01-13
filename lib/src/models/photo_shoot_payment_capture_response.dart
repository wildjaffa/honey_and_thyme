import 'package:honey_and_thyme/src/models/parsable.dart';

class PhotoShootPaymentCaptureResponse implements Parsable {
  bool? isSuccess;
  bool? shouldTryAgain;
  String? photoShootId;

  PhotoShootPaymentCaptureResponse({
    this.isSuccess,
    this.shouldTryAgain,
    this.photoShootId,
  });

  PhotoShootPaymentCaptureResponse.fromJson(dynamic json) {
    isSuccess = json['IsSuccess'];
    shouldTryAgain = json['ShouldTryAgain'];
    photoShootId = json['PhotoShootId'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['IsSuccess'] = isSuccess;
    data['ShouldTryAgain'] = shouldTryAgain;
    data['PhotoShootId'] = photoShootId;
    return data;
  }
}
