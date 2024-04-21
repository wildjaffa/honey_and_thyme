import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/admin/album/edit_album.dart';
import 'package:honey_and_thyme/src/models/album.dart';
import 'package:honey_and_thyme/src/models/enums/image_sizes.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/services/album_service.dart';
import 'package:honey_and_thyme/src/services/image_service.dart';
import 'package:honey_and_thyme/src/services/utils/image_utils.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';

import '../models/image.dart';
import '../widgets/fade_in_image_with_place_holder.dart';

class AdminView extends StatefulWidget {
  const AdminView({
    super.key,
  });

  static const String route = '/admin';

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final albums = AlbumService.fetchAlbums();

  bool addingAlbum = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentScreen: ScreensEnum.admin,
      child: Center(
        child: SizedBox(
          width: 300,
          child: FutureBuilder(
            future: albums,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return ListView.builder(
                itemCount: snapshot.data!.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      title: const Text('Create New Album'),
                      onTap: () => Navigator.of(context).pushNamed(
                        '${EditAlbum.route}',
                        arguments: Album(),
                      ),
                    );
                  }
                  return AlbumSummary(album: snapshot.data![index - 1]);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class AlbumSummary extends StatefulWidget {
  final Album album;
  const AlbumSummary({
    super.key,
    required this.album,
  });

  @override
  State<AlbumSummary> createState() => _AlbumSummaryState();
}

class _AlbumSummaryState extends State<AlbumSummary> {
  Future<ImageData?>? coverImage;

  @override
  void initState() {
    super.initState();
    if (widget.album.coverImageId != null) {
      coverImage = ImageService.getImageData(widget.album.coverImageId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).pushNamed(
        '${EditAlbum.route}?albumId=${widget.album.albumId}',
        arguments: widget.album,
      ),
      leading: widget.album.coverImageId != null
          ? FutureBuilder(
              future: coverImage,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError ||
                    snapshot.data?.metaData?.aspectRatio == null) {
                  return const Icon(Icons.error);
                }

                return FadeInImageWithPlaceHolder(
                  isSelected: false,
                  imageUrl: ImageService.getImageUrl(
                      widget.album.coverImageId!, ImageSizes.medium),
                  size: ImageUtils.calculateImageSize(
                      imageWidth: 50,
                      imageHeight: 50,
                      aspectRatio: snapshot.data!.metaData!.aspectRatio!),
                );
              },
            )
          : null,
      title: Text(widget.album.name!),
      subtitle: Text(widget.album.description!),
      trailing:
          Icon(widget.album.isLocked == true ? Icons.lock : Icons.lock_open),
    );
  }
}
