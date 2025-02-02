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
  String? imageId;
  String? fileName;
  DateTime? sortDate;
  MetaData? metaData;

  ImageData(
      {this.id, this.imageId, this.fileName, this.sortDate, this.metaData});

  ImageData.fromJson(Map<String, dynamic> json) {
    id = json['\$id'];
    imageId = json['imageId'];
    fileName = json['fileName'];
    sortDate = DateTime.parse(json['sortDate']);
    metaData =
        json['metaData'] != null ? MetaData?.fromJson(json['metaData']) : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['\$id'] = id;
    data['imageId'] = imageId;
    data['fileName'] = fileName;
    data['sortDate'] = sortDate?.toIso8601String();
    data['metaData'] = metaData!.toJson();
    return data;
  }
}
