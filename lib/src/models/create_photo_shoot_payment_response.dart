import 'package:honey_and_thyme/src/models/enums/payment_processors.dart';
import 'package:honey_and_thyme/src/models/parsable.dart';

class CreatePhotoShootPaymentResponse implements Parsable {
  String? photoShootId;
  String? processorOrderId;
  PaymentProcessors? processorEnum;
  bool? isSuccess;
  String? invoiceId;

  CreatePhotoShootPaymentResponse({
    this.photoShootId,
    this.processorOrderId,
    this.processorEnum,
    this.isSuccess,
    this.invoiceId,
  });

  CreatePhotoShootPaymentResponse.fromJson(dynamic json) {
    photoShootId = json['photoShootId'];
    processorOrderId = json['processorOrderId'];
    processorEnum = PaymentProcessors.values[json['processorEnum']];
    isSuccess = json['isSuccess'];
    invoiceId = json['invoiceId'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['photoShootId'] = photoShootId;
    data['processorOrderId'] = processorOrderId;
    data['processorEnum'] = processorEnum?.index;
    data['isSuccess'] = isSuccess;
    data['invoiceId'] = invoiceId;
    return data;
  }
}
