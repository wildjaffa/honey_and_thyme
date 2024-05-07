import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:honey_and_thyme/src/models/album.dart';
import 'package:honey_and_thyme/src/models/enums/image_sizes.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../utils/constants.dart';
import '../services/image_service.dart';

class ImageSlideshow extends StatefulWidget {
  final int initialImageIndex;
  final Album album;
  final bool isOpen;
  final ImageSizes imageSize;
  final void Function() onDismissed;
  const ImageSlideshow({
    super.key,
    required this.album,
    required this.imageSize,
    required this.onDismissed,
    required this.isOpen,
    required this.initialImageIndex,
  });

  @override
  State<ImageSlideshow> createState() => _ImageSlideshowState();
}

class _ImageSlideshowState extends State<ImageSlideshow> {
  final carouselController = CarouselController();

  final focusNode = FocusNode();

  @override
  void didUpdateWidget(ImageSlideshow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen) {
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isOpen) {
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return KeyboardListener(
      onKeyEvent: (value) => {
        if (value.logicalKey == LogicalKeyboardKey.arrowRight)
          {carouselController.nextPage()}
        else if (value.logicalKey == LogicalKeyboardKey.arrowLeft)
          {carouselController.previousPage()}
        else if (value.logicalKey == LogicalKeyboardKey.escape)
          {widget.onDismissed()}
      },
      focusNode: focusNode,
      child: Stack(
        children: [
          if (widget.isOpen)
            Container(
              width: screenWidth,
              height: screenHeight,
              color: Colors.black.withOpacity(0.4),
            ),
          Visibility(
            maintainState: true,
            maintainAnimation: true,
            maintainInteractivity: false,
            maintainSemantics: true,
            maintainSize: true,
            visible: widget.isOpen,
            child: CarouselSlider.builder(
              itemCount: widget.album.images!.values!.length,
              carouselController: carouselController,
              options: CarouselOptions(
                viewportFraction: 1,
                autoPlay: false,
                height: screenHeight,
                initialPage: widget.initialImageIndex,
              ),
              itemBuilder:
                  (BuildContext context, int itemIndex, int pageViewIndex) {
                final image = widget.album.images!.values![itemIndex]!;
                final smallImageUrl = ImageService.getImageUrl(
                    image.imageId!, widget.imageSize, widget.album.password);

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
          if (widget.isOpen) ...[
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                color: Constants.goldColor,
                icon: const Icon(Icons.close),
                onPressed: widget.onDismissed,
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
      ),
    );
  }
}
