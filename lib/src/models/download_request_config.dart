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
    exportConfigId = json['ExportConfigId'];
    name = json['Name'];
    type = json['Type'];
    size = json['Size'];
    keepFolders = json['KeepFolders'];
    watermarkText = json['WatermarkText'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ExportConfigId'] = exportConfigId;
    data['Name'] = name;
    data['Type'] = type;
    data['Size'] = size;
    data['KeepFolders'] = keepFolders;
    data['WatermarkText'] = watermarkText;
    return data;
  }
}
