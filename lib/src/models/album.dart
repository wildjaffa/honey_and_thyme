import 'image.dart';
import 'parsable.dart';

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
    albumId = json['AlbumId'];
    name = json['Name'];
    urlName = json['UrlName'];
    description = json['Description'];
    isPublic = json['IsPublic'];
    password = json['Password'];
    coverImageId = json['CoverImageId'];
    isLocked = json['IsLocked'];
    images =
        json['Images'] != null ? ImagesData?.fromJson(json['Images']) : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['\$id'] = id;
    data['AlbumId'] = albumId;
    data['Name'] = name;
    data['UrlName'] = urlName;
    data['Description'] = description;
    data['IsPublic'] = isPublic;
    data['Password'] = password;
    data['CoverImageId'] = coverImageId;
    data['IsLocked'] = isLocked;
    data['Images'] = images?.toJson() ?? [];
    return data;
  }
}
