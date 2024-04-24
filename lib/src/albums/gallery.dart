import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';

import '../models/album.dart';
import '../models/enums/image_sizes.dart';
import '../services/album_service.dart';
import '../services/image_service.dart';
import '../services/utils/image_utils.dart';
import '../widgets/fade_in_image_with_place_holder.dart';

class PublicGallery extends StatefulWidget {
  const PublicGallery({super.key});

  static const String route = '/gallery';

  @override
  State<PublicGallery> createState() => _PublicGalleryState();
}

class _PublicGalleryState extends State<PublicGallery> {
  final Future<Album?> album = AlbumService.fetchAlbumByName('gallery', null);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentScreen: ScreensEnum.gallery,
      child: FutureBuilder(
        future: album,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text('No images found'),
            );
          }
          final album = snapshot.data as Album;
          var itemCount = album.images!.values?.length ?? 0;
          if (itemCount == 0) {
            return const Center(
              child: Text('No images found in this album'),
            );
          }

          final screenWidth = MediaQuery.of(context).size.width;
          var crossAxisCount = 2;
          var imageSize = ImageSizes.medium;
          if (screenWidth > 500) {
            crossAxisCount = 3;
          }
          if (screenWidth > 750) {
            crossAxisCount = 4;
            imageSize = ImageSizes.large;
          }
          if (screenWidth > 1000) {
            crossAxisCount = 5;
          }
          final imageWidth = screenWidth / crossAxisCount;
          return CustomScrollView(
            slivers: [
              SliverMasonryGrid(
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= itemCount) {
                      return null;
                    }
                    final image = album.images!.values![index]!;
                    return FadeInImageWithPlaceHolder(
                      imageUrl: ImageService.getImageUrl(
                          image.imageId!, imageSize, null),
                      size: ImageUtils.calculateImageSize(
                          imageWidth: imageWidth,
                          aspectRatio: image.metaData?.aspectRatio ?? 1),
                    );
                  },
                ),
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  const Padding(
                    padding: EdgeInsets.only(bottom: 50, top: 50),
                    child: Center(
                      child: Image(
                        image: AssetImage('assets/images/logo.png'),
                        width: 300,
                        height: 300,
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}
