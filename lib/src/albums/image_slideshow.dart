import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/models/album.dart';
import 'package:honey_and_thyme/src/models/enums/image_sizes.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../utils/constants.dart';
import '../services/image_service.dart';

class ImageSlideshow extends StatelessWidget {
  final CarouselController carouselController;
  final int? slideShowImageIndex;
  final Album album;
  final ImageSizes imageSize;
  final void Function() onDismissed;
  final void Function() onPreviousTapped;
  final void Function() onNextTapped;
  const ImageSlideshow({
    super.key,
    required this.carouselController,
    required this.slideShowImageIndex,
    required this.album,
    required this.imageSize,
    required this.onDismissed,
    required this.onPreviousTapped,
    required this.onNextTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Visibility(
          maintainState: true,
          maintainAnimation: true,
          visible: slideShowImageIndex != null,
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
                color: Colors.black.withOpacity(0.8),
                child: FadeInImage.memoryNetwork(
                  fadeInDuration: const Duration(milliseconds: 100),
                  placeholder: kTransparentImage,
                  image: smallImageUrl,
                ),
              );
            },
          ),
        ),
        if (slideShowImageIndex != null)
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              color: Constants.goldColor,
              icon: const Icon(Icons.close),
              onPressed: onDismissed,
            ),
          ),
        if (slideShowImageIndex != null && slideShowImageIndex! > 0)
          Positioned(
            left: 5,
            top: (screenHeight - 24) / 2,
            child: IconButton(
              color: Constants.goldColor,
              icon: const Icon(Icons.arrow_back),
              onPressed: onPreviousTapped,
            ),
          ),
        if (slideShowImageIndex != null &&
            slideShowImageIndex! < album.images!.values!.length - 1)
          Positioned(
            right: 5,
            top: (screenHeight - 24) / 2,
            child: IconButton(
              color: Constants.goldColor,
              icon: const Icon(Icons.arrow_forward),
              onPressed: onNextTapped,
            ),
          ),
      ],
    );
  }
}
