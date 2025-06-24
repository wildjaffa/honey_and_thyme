import 'package:honey_and_thyme/src/models/enums/photo_shoot_status.dart';
import 'package:honey_and_thyme/src/models/enums/photo_shoot_type.dart';

import 'parsable.dart';

class PhotoShoots implements Parsable {
  String? id;
  List<PhotoShoot?>? values;

  PhotoShoots({
    this.id,
    this.values,
  });

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
  DateTime? endDateTimeUtc;
  String? location;
  double? price;
  double? deposit;
  double? discount;
  String? discountName;
  double? paymentRemaining;
  PhotoShootType? photoShootType;
  PhotoShootStatus? status;
  String? albumId;

  PhotoShoot({
    this.photoShootId,
    this.responsiblePartyName,
    this.responsiblePartyEmailAddress,
    this.nameOfShoot,
    this.description,
    this.dateTimeUtc,
    this.endDateTimeUtc,
    this.location,
    this.price,
    this.deposit,
    this.discount,
    this.discountName,
    this.paymentRemaining,
    this.status,
    this.photoShootType,
    this.albumId,
  }) {
    price ??= 0.0;
    deposit ??= 0.0;
    discount ??= 0.0;
    paymentRemaining ??= 0.0;
    dateTimeUtc ??= DateTime.now().toUtc();
  }

  PhotoShoot.fromJson(dynamic json) {
    photoShootId = json['photoShootId'];
    responsiblePartyName = json['responsiblePartyName'];
    responsiblePartyEmailAddress = json['responsiblePartyEmailAddress'];
    nameOfShoot = json['nameOfShoot'];
    description = json['description'];
    dateTimeUtc = DateTime.parse(json['dateTimeUtc']);
    endDateTimeUtc = json['endDateTimeUtc'] != null
        ? DateTime.parse(json['endDateTimeUtc'])
        : null;
    location = json['location'];
    price = json['price'];
    deposit = json['deposit'];
    discount = json['discount'];
    discountName = json['discountName'];
    paymentRemaining = json['paymentRemaining'];
    photoShootType = PhotoShootType.values[json['photoShootType']];
    status = PhotoShootStatus.values[json['status']];
    albumId = json['albumId'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['photoShootId'] = photoShootId;
    data['responsiblePartyName'] = responsiblePartyName;
    data['responsiblePartyEmailAddress'] = responsiblePartyEmailAddress;
    data['nameOfShoot'] = nameOfShoot;
    data['description'] = description;
    data['dateTimeUtc'] = dateTimeUtc?.toUtc().toIso8601String();
    data['endDateTimeUtc'] = endDateTimeUtc?.toUtc().toIso8601String();
    data['location'] = location;
    data['price'] = price;
    data['deposit'] = deposit;
    data['discount'] = discount;
    data['discountName'] = discountName;
    data['paymentRemaining'] = paymentRemaining;
    data['photoShootType'] = photoShootType?.index;
    data['status'] = status?.index;
    data['albumId'] = albumId;
    return data;
  }
}
