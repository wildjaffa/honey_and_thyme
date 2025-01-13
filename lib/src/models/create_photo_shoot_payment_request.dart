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
    photoShootId = json['PhotoShootId'];
    amount = json['Amount'];
    paymentProcessorEnum =
        PaymentProcessors.values[json['PaymentProcessorEnum']];
    description = json['Description'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PhotoShootId'] = photoShootId;
    data['Amount'] = amount;
    data['PaymentProcessorEnum'] = paymentProcessorEnum?.index;
    data['Description'] = description;
    return data;
  }
}
