import 'meta_data.dart';
import 'parsable.dart';

class ImagesData implements Parsable {
  String? id;
  List<ImageData?>? values;

  ImagesData({this.id, this.values});

  ImagesData.fromJson(Map<String, dynamic> json) {
    id = json['\$id'];
    if (json['\$values'] != null) {
      values = <ImageData>[];
      json['\$values'].forEach((v) {
        values!.add(ImageData.fromJson(v));
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

class ImageData implements Parsable {
  String? id;
  int? imageId;
  String? fileName;
  DateTime? sortDate;
  MetaData? metaData;

  ImageData(
      {this.id, this.imageId, this.fileName, this.sortDate, this.metaData});

  ImageData.fromJson(Map<String, dynamic> json) {
    id = json['\$id'];
    imageId = json['ImageId'];
    fileName = json['FileName'];
    sortDate = DateTime.parse(json['SortDate']);
    metaData =
        json['MetaData'] != null ? MetaData?.fromJson(json['MetaData']) : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['\$id'] = id;
    data['ImageId'] = imageId;
    data['FileName'] = fileName;
    data['SortDate'] = sortDate?.toIso8601String();
    data['MetaData'] = metaData!.toJson();
    return data;
  }
}
