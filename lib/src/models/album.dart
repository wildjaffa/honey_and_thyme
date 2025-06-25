import 'package:honey_and_thyme/src/models/pagination_result.dart';

import 'image.dart';
import 'parsable.dart';

class PaginatedAlbums extends PaginationResult<Album> implements Parsable {
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

  PaginatedAlbums.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <Album>[];
      json['results']['\$values'].forEach((v) {
        results!.add(Album.fromJson(v));
      });
    }
    pageIndex = json['pageIndex'];
    pageSize = json['pageSize'];
    pageCount = json['pageCount'];
    totalCount = json['totalCount'];
  }
}

class Albums implements Parsable {
  String? id;
  List<Album?>? values;

  Albums({this.id, this.values});

  Albums.fromJson(Map<String, dynamic> json) {
    id = json['\$id'];
    if (json['\$values'] != null) {
      values = <Album>[];
      json['\$values'].forEach((v) {
        values!.add(Album.fromJson(v));
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

class Album implements Parsable {
  String? id;
  String? albumId;
  String? name;
  String? urlName;
  String? description;
  bool? isPublic;
  String? password;
  String? coverImageId;
  bool? isLocked;
  ImagesData? images;

  Album(
      {this.id,
      this.albumId,
      this.name,
      this.urlName,
      this.description,
      this.isPublic,
      this.password,
      this.coverImageId,
      this.isLocked,
      this.images});

  Album.fromJson(dynamic json) {
    id = json['\$id'];
    albumId = json['albumId'];
    name = json['name'];
    urlName = json['urlName'];
    description = json['description'];
    isPublic = json['isPublic'];
    password = json['password'];
    coverImageId = json['coverImageId'];
    isLocked = json['isLocked'];
    images =
        json['images'] != null ? ImagesData?.fromJson(json['images']) : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['\$id'] = id;
    data['albumId'] = albumId;
    data['name'] = name;
    data['urlName'] = urlName;
    data['description'] = description;
    data['isPublic'] = isPublic;
    data['password'] = password;
    data['coverImageId'] = coverImageId;
    data['isLocked'] = isLocked;
    data['images'] = images?.toJson() ?? [];
    return data;
  }
}
