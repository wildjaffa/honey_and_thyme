import 'parsable.dart';

class PhotoShoots implements Parsable {
  String? id;
  List<PhotoShoot?>? values;

  PhotoShoots({this.id, this.values});

  PhotoShoots.fromJson(dynamic json) {
    id = json['\$id'];
    if (json['\$values'] != null) {
      values = <PhotoShoot>[];
      json['\$values'].forEach((v) {
        values!.add(PhotoShoot.fromJson(v));
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

class PhotoShoot implements Parsable {
  String? photoShootId;
  String? responsiblePartyName;
  String? responsiblePartyEmailAddress;
  String? nameOfShoot;
  String? description;
  DateTime? dateTimeUtc;
  double? price;
  double? deposit;
  double? discount;
  String? discountName;
  bool? isConfirmed;
  double? paymentRemaining;
  bool? picturesDelivered;

  PhotoShoot({
    this.photoShootId,
    this.responsiblePartyName,
    this.responsiblePartyEmailAddress,
    this.nameOfShoot,
    this.description,
    this.dateTimeUtc,
    this.price,
    this.deposit,
    this.discount,
    this.discountName,
    this.isConfirmed,
    this.paymentRemaining,
    this.picturesDelivered,
  }) {
    price ??= 0.0;
    deposit ??= 0.0;
    discount ??= 0.0;
    isConfirmed ??= false;
    paymentRemaining ??= 0.0;
    dateTimeUtc ??= DateTime.now().toUtc();
    picturesDelivered ??= false;
  }

  PhotoShoot.fromJson(dynamic json) {
    photoShootId = json['PhotoShootId'];
    responsiblePartyName = json['ResponsiblePartyName'];
    responsiblePartyEmailAddress = json['ResponsiblePartyEmailAddress'];
    nameOfShoot = json['NameOfShoot'];
    description = json['Description'];
    dateTimeUtc = DateTime.parse(json['DateTimeUtc']);
    price = json['Price'];
    deposit = json['Deposit'];
    discount = json['Discount'];
    discountName = json['DiscountName'];
    isConfirmed = json['IsConfirmed'];
    paymentRemaining = json['PaymentRemaining'];
    picturesDelivered = json['PicturesDelivered'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PhotoShootId'] = photoShootId;
    data['ResponsiblePartyName'] = responsiblePartyName;
    data['ResponsiblePartyEmailAddress'] = responsiblePartyEmailAddress;
    data['NameOfShoot'] = nameOfShoot;
    data['Description'] = description;
    data['DateTimeUtc'] = dateTimeUtc?.toIso8601String();
    data['Price'] = price;
    data['Deposit'] = deposit;
    data['Discount'] = discount;
    data['DiscountName'] = discountName;
    data['IsConfirmed'] = isConfirmed;
    data['PaymentRemaining'] = paymentRemaining;
    data['PicturesDelivered'] = picturesDelivered;
    return data;
  }
}
