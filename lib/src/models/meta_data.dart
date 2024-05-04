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
    metaDataId = json['MetaDataId'];
    imageId = json['ImageId'];
    width = json['Width'];
    height = json['Height'];
    aspectRatio = json['AspectRatio'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['\$id'] = id;
    data['MetaDataId'] = metaDataId;
    data['ImageId'] = imageId;
    data['Width'] = width;
    data['Height'] = height;
    data['AspectRatio'] = aspectRatio;
    return data;
  }
}
