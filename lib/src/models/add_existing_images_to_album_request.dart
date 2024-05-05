class AddExistingImagesToAlbumRequest {
  String? albumId;
  List<String?>? imageIds;

  AddExistingImagesToAlbumRequest({this.albumId, this.imageIds});

  AddExistingImagesToAlbumRequest.fromJson(Map<String, dynamic> json) {
    albumId = json['AlbumId'];
    if (json['ImageIds'] != null) {
      imageIds = <String>[];
      json['ImageIds'].forEach((v) {
        imageIds!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['AlbumId'] = albumId;
    data['ImageIds'] = imageIds;
    return data;
  }
}
