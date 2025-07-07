import 'package:honey_and_thyme/src/models/enums/photo_shoot_status.dart';
import 'package:honey_and_thyme/src/models/enums/photo_shoot_type.dart';

import 'pagination_result.dart';
import 'parsable.dart';

class PaginatedPhotoShoots extends PaginationResult<PhotoShoot>
    implements Parsable {
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['values'] = results?.map((v) => v.toJson()).toList();
    data['pageIndex'] = pageIndex;
    data['pageSize'] = pageSize;
    data['pageCount'] = pageCount;
    data['totalCount'] = totalCount;
    return data;
  }

  PaginatedPhotoShoots.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <PhotoShoot>[];
      json['results']['\$values'].forEach((v) {
        results!.add(PhotoShoot.fromJson(v));
      });
    }
    pageIndex = json['pageIndex'];
    pageSize = json['pageSize'];
    pageCount = json['pageCount'];
    totalCount = json['totalCount'];
  }
}

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
  String? reservationCode;

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
    this.photoShootType = PhotoShootType.customBooking,
    this.albumId,
    this.reservationCode,
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
    reservationCode = json['reservationCode'];
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
    data['reservationCode'] = reservationCode;
    return data;
  }
}
