import 'package:honey_and_thyme/src/models/enums/payment_processors.dart';
import 'package:honey_and_thyme/src/models/parsable.dart';

class CreatePhotoShootPaymentRequest implements Parsable {
  String? photoShootId;
  double? amount;
  PaymentProcessors? paymentProcessorEnum;
  String? description;

  CreatePhotoShootPaymentRequest({
    this.photoShootId,
    this.amount,
    this.paymentProcessorEnum,
    this.description,
  });

  CreatePhotoShootPaymentRequest.fromJson(Map<String, dynamic> json) {
    photoShootId = json['photoShootId'];
    amount = json['amount'];
    paymentProcessorEnum =
        PaymentProcessors.values[json['paymentProcessorEnum']];
    description = json['description'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['photoShootId'] = photoShootId;
    data['amount'] = amount;
    data['paymentProcessorEnum'] = paymentProcessorEnum?.index;
    data['description'] = description;
    return data;
  }
}
