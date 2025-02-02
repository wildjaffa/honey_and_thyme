class DownloadRequestConfig {
  int? exportConfigId;
  String? name;
  int? type;
  int? size;
  bool? keepFolders;
  String? watermarkText;

  DownloadRequestConfig({
    this.exportConfigId,
    this.name,
    this.type,
    this.size,
    this.keepFolders,
    this.watermarkText,
  });

  DownloadRequestConfig.fromJson(dynamic json) {
    exportConfigId = json['exportConfigId'];
    name = json['name'];
    type = json['type'];
    size = json['size'];
    keepFolders = json['keepFolders'];
    watermarkText = json['watermarkText'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['exportConfigId'] = exportConfigId;
    data['name'] = name;
    data['type'] = type;
    data['size'] = size;
    data['keepFolders'] = keepFolders;
    data['watermarkText'] = watermarkText;
    return data;
  }
}
