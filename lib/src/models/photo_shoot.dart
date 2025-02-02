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
    photoShootId = json['photoShootId'];
    responsiblePartyName = json['responsiblePartyName'];
    responsiblePartyEmailAddress = json['responsiblePartyEmailAddress'];
    nameOfShoot = json['nameOfShoot'];
    description = json['description'];
    dateTimeUtc = DateTime.parse(json['dateTimeUtc']);
    price = json['price'];
    deposit = json['deposit'];
    discount = json['discount'];
    discountName = json['discountName'];
    isConfirmed = json['isConfirmed'];
    paymentRemaining = json['paymentRemaining'];
    picturesDelivered = json['picturesDelivered'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['photoShootId'] = photoShootId;
    data['responsiblePartyName'] = responsiblePartyName;
    data['responsiblePartyEmailAddress'] = responsiblePartyEmailAddress;
    data['nameOfShoot'] = nameOfShoot;
    data['description'] = description;
    data['dateTimeUtc'] = dateTimeUtc?.toIso8601String();
    data['price'] = price;
    data['deposit'] = deposit;
    data['discount'] = discount;
    data['discountName'] = discountName;
    data['isConfirmed'] = isConfirmed;
    data['paymentRemaining'] = paymentRemaining;
    data['picturesDelivered'] = picturesDelivered;
    return data;
  }
}
