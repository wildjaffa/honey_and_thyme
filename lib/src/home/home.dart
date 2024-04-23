import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/models/enums/image_sizes.dart';
import 'package:honey_and_thyme/src/models/image.dart';
import 'package:honey_and_thyme/src/services/image_service.dart';
import 'package:honey_and_thyme/src/services/utils/image_utils.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:transparent_image/transparent_image.dart';

import '../models/album.dart';
import '../models/enums/screens.dart';
import '../services/album_service.dart';

class Home extends StatelessWidget {
  Home({
    super.key,
  });

  final Future<Album?> album =
      AlbumService.fetchAlbumByName('site-images', null);

  static const List<int> imageIds = [
    131,
    130,
    133,
    129,
    132,
    128,
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentScreen: ScreensEnum.home,
      child: FutureBuilder(
        future: album,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('Sorry, there was an issue loading the images.'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return MobileView(
                  imageIds: imageIds,
                  album: snapshot.data!,
                );
              } else {
                return DesktopView(
                  imageIds: imageIds,
                  album: snapshot.data!,
                );
              }
            },
          );
        },
      ),
    );
  }
}

class MobileView extends StatefulWidget {
  final Album album;
  final List<int> imageIds;
  const MobileView({
    super.key,
    required this.album,
    required this.imageIds,
  });

  @override
  State<MobileView> createState() => _MobileViewState();
}

class _MobileViewState extends State<MobileView>
    with SingleTickerProviderStateMixin {
  late final AnimationController imagesController = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
    upperBound: 3,
    lowerBound: 0,
  );

  @override
  void initState() {
    super.initState();
    imagesController.forward();
  }

  @override
  void dispose() {
    imagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 40),
            child: SizedBox(
              height: 300,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: HomePageImage(
                      height: 150, // 2/3
                      width: 150,
                      image: widget.album.images!.values!.firstWhere(
                          (image) => image!.imageId == widget.imageIds[0])!,
                      delayInSeconds: 0,
                      controller: imagesController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: HomePageImage(
                      width: 175,
                      image: widget.album.images!.values!.firstWhere(
                          (image) => image!.imageId == widget.imageIds[1])!,
                      delayInSeconds: 2,
                      controller: imagesController,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 300,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: HomePageImage(
                      width: 175,
                      image: widget.album.images!.values!.firstWhere(
                          (image) => image!.imageId == widget.imageIds[3])!,
                      delayInSeconds: 3,
                      controller: imagesController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: HomePageImage(
                      width: 165,
                      image: widget.album.images!.values!.firstWhere(
                          (image) => image!.imageId == widget.imageIds[4])!,
                      delayInSeconds: 1,
                      controller: imagesController,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DesktopView extends StatefulWidget {
  final Album album;
  final List<int> imageIds;
  const DesktopView({
    super.key,
    required this.imageIds,
    required this.album,
  });

  @override
  State<DesktopView> createState() => _DesktopViewState();
}

class _DesktopViewState extends State<DesktopView>
    with SingleTickerProviderStateMixin {
  late final AnimationController imagesController = AnimationController(
    duration: const Duration(seconds: 5),
    vsync: this,
    upperBound: 5,
    lowerBound: 0,
  );

  @override
  void initState() {
    super.initState();
    imagesController.forward();
  }

  @override
  void dispose() {
    imagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 40),
          child: SizedBox(
            height: 300,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: HomePageImage(
                    height: 150,
                    width: 150,
                    image: widget.album.images!.values!.firstWhere(
                        (image) => image!.imageId == widget.imageIds[0])!,
                    delayInSeconds: 0,
                    controller: imagesController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: HomePageImage(
                    height: 300,
                    width: 200,
                    image: widget.album.images!.values!.firstWhere(
                        (image) => image!.imageId == widget.imageIds[1])!,
                    delayInSeconds: 2,
                    controller: imagesController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: HomePageImage(
                    height: 200,
                    width: 200,
                    image: widget.album.images!.values!.firstWhere(
                        (image) => image!.imageId == widget.imageIds[2])!,
                    delayInSeconds: 4,
                    controller: imagesController,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 300,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: HomePageImage(
                    width: 200,
                    image: widget.album.images!.values!.firstWhere(
                        (image) => image!.imageId == widget.imageIds[3])!,
                    delayInSeconds: 3,
                    controller: imagesController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: HomePageImage(
                    width: 200,
                    image: widget.album.images!.values!.firstWhere(
                        (image) => image!.imageId == widget.imageIds[4])!,
                    delayInSeconds: 5,
                    controller: imagesController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: HomePageImage(
                    width: 200, // 16/9
                    image: widget.album.images!.values!.firstWhere(
                        (image) => image!.imageId == widget.imageIds[5])!,
                    delayInSeconds: 1,
                    controller: imagesController,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HomePageImage extends StatelessWidget {
  final ImageData image;
  final AnimationController controller;
  final double delayInSeconds;
  final double? height;
  final double? width;

  const HomePageImage({
    super.key,
    required this.image,
    required this.delayInSeconds,
    this.height,
    this.width,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final imageSize = ImageUtils.calculateImageSize(
      aspectRatio: image.metaData!.aspectRatio!,
      imageHeight: height,
      imageWidth: width,
    );
    return AnimatedBuilder(
      animation: controller,
      builder: ((context, snapshot) {
        if (controller.value >= delayInSeconds) {
          return FadeInImage.memoryNetwork(
            height: imageSize.height,
            width: imageSize.width,
            placeholder: kTransparentImage,
            image: ImageService.getImageUrl(
                image.imageId!, ImageSizes.medium, null),
          );
        } else {
          return SizedBox(height: height, width: width);
        }
      }),
    );
  }
}
