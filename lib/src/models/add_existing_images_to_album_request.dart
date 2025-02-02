class AddExistingImagesToAlbumRequest {
  String? albumId;
  List<String?>? imageIds;

  AddExistingImagesToAlbumRequest({this.albumId, this.imageIds});

  AddExistingImagesToAlbumRequest.fromJson(Map<String, dynamic> json) {
    albumId = json['albumId'];
    if (json['imageIds'] != null) {
      imageIds = <String>[];
      json['imageIds'].forEach((v) {
        imageIds!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['albumId'] = albumId;
    data['imageIds'] = imageIds;
    return data;
  }
}
