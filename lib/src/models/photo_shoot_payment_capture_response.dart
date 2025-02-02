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
    isSuccess = json['isSuccess'];
    shouldTryAgain = json['shouldTryAgain'];
    photoShootId = json['photoShootId'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isSuccess'] = isSuccess;
    data['shouldTryAgain'] = shouldTryAgain;
    data['photoShootId'] = photoShootId;
    return data;
  }
}
