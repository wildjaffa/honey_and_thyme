import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/models/album.dart';
import 'package:honey_and_thyme/src/models/enums/image_sizes.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../utils/constants.dart';
import '../services/image_service.dart';

class ImageSlideshow extends StatelessWidget {
  final CarouselController carouselController;
  final Album album;
  final bool isOpen;
  final ImageSizes imageSize;
  final void Function() onDismissed;
  const ImageSlideshow({
    super.key,
    required this.carouselController,
    required this.album,
    required this.imageSize,
    required this.onDismissed,
    required this.isOpen,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        if (isOpen)
          Container(
            width: screenWidth,
            height: screenHeight,
            color: Colors.black.withOpacity(0.4),
          ),
        Visibility(
          maintainState: true,
          maintainAnimation: true,
          visible: isOpen,
          child: CarouselSlider.builder(
            itemCount: album.images!.values!.length,
            carouselController: carouselController,
            options: CarouselOptions(
              viewportFraction: 1,
              autoPlay: false,
              height: screenHeight,
            ),
            itemBuilder:
                (BuildContext context, int itemIndex, int pageViewIndex) {
              final image = album.images!.values![itemIndex]!;
              final smallImageUrl = ImageService.getImageUrl(
                  image.imageId!, imageSize, album.password);

              return Container(
                width: screenWidth,
                height: screenHeight,
                color: Colors.black.withOpacity(0.4),
                child: FadeInImage.memoryNetwork(
                  fadeInDuration: const Duration(milliseconds: 100),
                  placeholder: kTransparentImage,
                  image: smallImageUrl,
                ),
              );
            },
          ),
        ),
        if (isOpen) ...[
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              color: Constants.goldColor,
              icon: const Icon(Icons.close),
              onPressed: onDismissed,
            ),
          ),
          Positioned(
            left: 5,
            top: (screenHeight - 24) / 2,
            child: IconButton(
              color: Constants.goldColor,
              icon: const Icon(Icons.arrow_back),
              onPressed: carouselController.previousPage,
            ),
          ),
          Positioned(
            right: 5,
            top: (screenHeight - 24) / 2,
            child: IconButton(
              color: Constants.goldColor,
              icon: const Icon(Icons.arrow_forward),
              onPressed: carouselController.nextPage,
            ),
          ),
        ]
      ],
    );
  }
}
