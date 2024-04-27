import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/models/enums/image_sizes.dart';
import 'package:honey_and_thyme/src/models/image.dart';
import 'package:honey_and_thyme/src/services/image_service.dart';
import 'package:honey_and_thyme/src/services/utils/image_utils.dart';
import 'package:honey_and_thyme/src/widgets/app_footer.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:transparent_image/transparent_image.dart';

import '../models/album.dart';
import '../models/enums/screens.dart';
import '../services/album_service.dart';

class Home extends StatelessWidget {
  final bool slowLoadImages;
  Home({
    super.key,
    required this.slowLoadImages,
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
                  slowLoadImages: slowLoadImages,
                );
              } else {
                return DesktopView(
                  imageIds: imageIds,
                  album: snapshot.data!,
                  slowLoadImages: slowLoadImages,
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
  final bool slowLoadImages;
  const MobileView({
    super.key,
    required this.album,
    required this.imageIds,
    required this.slowLoadImages,
  });

  @override
  State<MobileView> createState() => _MobileViewState();
}

class _MobileViewState extends State<MobileView>
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0),
            child: SizedBox(
              height: 250,
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
                      delayInSeconds: widget.slowLoadImages ? 0 : 2,
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
              height: 350,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: HomePageImage(
                          width: 175,
                          image: widget.album.images!.values!.firstWhere(
                              (image) => image!.imageId == widget.imageIds[3])!,
                          delayInSeconds: widget.slowLoadImages ? 0 : 3,
                          controller: imagesController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8, top: 8),
                        child: HomePageImage(
                          width: 175,
                          image: widget.album.images!.values!.firstWhere(
                              (image) => image!.imageId == widget.imageIds[2])!,
                          delayInSeconds: widget.slowLoadImages ? 0 : 5,
                          controller: imagesController,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: HomePageImage(
                          width: 165,
                          image: widget.album.images!.values!.firstWhere(
                              (image) => image!.imageId == widget.imageIds[4])!,
                          delayInSeconds: widget.slowLoadImages ? 0 : 1,
                          controller: imagesController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8, top: 8),
                        child: HomePageImage(
                          width: 165,
                          image: widget.album.images!.values!.firstWhere(
                              (image) => image!.imageId == widget.imageIds[5])!,
                          delayInSeconds: widget.slowLoadImages ? 0 : 4,
                          controller: imagesController,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}

class DesktopView extends StatefulWidget {
  final Album album;
  final List<int> imageIds;
  final bool slowLoadImages;
  const DesktopView({
    super.key,
    required this.imageIds,
    required this.album,
    required this.slowLoadImages,
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
    final contentHeight = MediaQuery.of(context).size.height -
        AppScaffold.appBarHeight -
        AppFooter.footerHeight;
    final contentWidth = MediaQuery.of(context).size.width;
    double rowWidth = contentWidth - 150;
    double rowHeight = rowWidth / 2;
    if (contentWidth > 1050) {
      rowWidth = 900;
      rowHeight = 450;
    }
    final widthRatio = rowWidth / 600;
    final heightRatio = rowHeight / 300;
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 40),
            child: SizedBox(
              height: rowHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: HomePageImage(
                      height: 150 * heightRatio,
                      width: 150 * widthRatio,
                      image: widget.album.images!.values!.firstWhere(
                          (image) => image!.imageId == widget.imageIds[0])!,
                      delayInSeconds: 0,
                      controller: imagesController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: HomePageImage(
                      height: 300 * heightRatio,
                      width: 200 * widthRatio,
                      image: widget.album.images!.values!.firstWhere(
                          (image) => image!.imageId == widget.imageIds[1])!,
                      delayInSeconds: widget.slowLoadImages ? 0 : 2,
                      controller: imagesController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: HomePageImage(
                      height: 200 * heightRatio,
                      width: 200 * widthRatio,
                      image: widget.album.images!.values!.firstWhere(
                          (image) => image!.imageId == widget.imageIds[2])!,
                      delayInSeconds: widget.slowLoadImages ? 0 : 4,
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
              height: rowHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: HomePageImage(
                      width: 190 * widthRatio,
                      image: widget.album.images!.values!.firstWhere(
                          (image) => image!.imageId == widget.imageIds[3])!,
                      delayInSeconds: widget.slowLoadImages ? 0 : 3,
                      controller: imagesController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: HomePageImage(
                      width: 187 * widthRatio,
                      image: widget.album.images!.values!.firstWhere(
                          (image) => image!.imageId == widget.imageIds[4])!,
                      delayInSeconds: widget.slowLoadImages ? 0 : 5,
                      controller: imagesController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: HomePageImage(
                      width: 190 * widthRatio,
                      image: widget.album.images!.values!.firstWhere(
                          (image) => image!.imageId == widget.imageIds[5])!,
                      delayInSeconds: widget.slowLoadImages ? 0 : 1,
                      controller: imagesController,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
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
            fadeInDuration: const Duration(milliseconds: 1000),
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
