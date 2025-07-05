import 'package:honey_and_thyme/src/models/enums/payment_processors.dart';
import 'package:honey_and_thyme/src/models/parsable.dart';

class CreatePhotoShootPaymentResponse implements Parsable {
  String? reservationCode;
  String? processorOrderId;
  PaymentProcessors? processorEnum;
  bool? isSuccess;
  String? invoiceId;

  CreatePhotoShootPaymentResponse({
    this.reservationCode,
    this.processorOrderId,
    this.processorEnum,
    this.isSuccess,
    this.invoiceId,
  });

  CreatePhotoShootPaymentResponse.fromJson(dynamic json) {
    reservationCode = json['reservationCode'];
    processorOrderId = json['processorOrderId'];
    processorEnum = PaymentProcessors.values[json['processorEnum']];
    isSuccess = json['isSuccess'];
    invoiceId = json['invoiceId'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reservationCode'] = reservationCode;
    data['processorOrderId'] = processorOrderId;
    data['processorEnum'] = processorEnum?.index;
    data['isSuccess'] = isSuccess;
    data['invoiceId'] = invoiceId;
    return data;
  }
}
