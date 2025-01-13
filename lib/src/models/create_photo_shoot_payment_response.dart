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
    photoShootId = json['PhotoShootId'];
    processorOrderId = json['ProcessorOrderId'];
    processorEnum = PaymentProcessors.values[json['ProcessorEnum']];
    isSuccess = json['IsSuccess'];
    invoiceId = json['InvoiceId'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PhotoShootId'] = photoShootId;
    data['ProcessorOrderId'] = processorOrderId;
    data['ProcessorEnum'] = processorEnum?.index;
    data['IsSuccess'] = isSuccess;
    data['InvoiceId'] = invoiceId;
    return data;
  }
}
