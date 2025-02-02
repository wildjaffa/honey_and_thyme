import 'package:honey_and_thyme/src/models/enums/payment_processors.dart';

import 'parsable.dart';

class PaymentTransactions implements Parsable {
  String? id;
  List<PaymentTransaction?>? values;

  PaymentTransactions({this.id, this.values});

  PaymentTransactions.fromJson(Map<String, dynamic> json) {
    id = json['\$id'];
    if (json['\$values'] != null) {
      values = <PaymentTransaction>[];
      json['\$values'].forEach((v) {
        values!.add(PaymentTransaction.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['\$id'] = id;
    data['\$values'] = values?.map((v) => v?.toJson()).toList();
    return data;
  }
}

class PaymentTransaction implements Parsable {
  String? paymentTransactionId;
  String? photoShootId;
  DateTime? dateTimeUtc;
  double? amount;
  String? description;
  PaymentProcessors? paymentProcessorType;
  String? externalId;

  PaymentTransaction({
    this.paymentTransactionId,
    this.photoShootId,
    this.dateTimeUtc,
    this.amount,
    this.description,
    this.paymentProcessorType,
    this.externalId,
  });

  PaymentTransaction.fromJson(dynamic json) {
    paymentTransactionId = json['paymentTransactionId'];
    photoShootId = json['photoShootId'];
    dateTimeUtc = DateTime.parse(json['dateTimeUtc']);
    amount = json['amount'];
    description = json['description'];
    paymentProcessorType =
        PaymentProcessors.values[json['paymentProcessorType']];
    externalId = json['externalId'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['paymentTransactionId'] = paymentTransactionId;
    data['photoShootId'] = photoShootId;
    data['dateTimeUtc'] = dateTimeUtc?.toIso8601String();
    data['amount'] = amount;
    data['description'] = description;
    data['paymentProcessorType'] = paymentProcessorType?.index;
    data['externalId'] = externalId;
    return data;
  }
}
