import 'parsable.dart';

class MetaData implements Parsable {
  String? id;
  String? metaDataId;
  String? imageId;
  int? width;
  int? height;
  double? aspectRatio;

  MetaData(
      {this.id,
      this.metaDataId,
      this.imageId,
      this.width,
      this.height,
      this.aspectRatio});

  MetaData.fromJson(Map<String, dynamic> json) {
    id = json['\$id'];
    metaDataId = json['metaDataId'];
    imageId = json['imageId'];
    width = json['width'];
    height = json['height'];
    aspectRatio = json['aspectRatio'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['\$id'] = id;
    data['metaDataId'] = metaDataId;
    data['imageId'] = imageId;
    data['width'] = width;
    data['height'] = height;
    data['aspectRatio'] = aspectRatio;
    return data;
  }
}
