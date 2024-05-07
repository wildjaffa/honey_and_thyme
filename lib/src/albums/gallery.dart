import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/albums/image_gallery.dart';
import 'package:honey_and_thyme/src/albums/image_slideshow.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/widgets/app_bar.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';

import '../models/album.dart';
import '../models/enums/image_sizes.dart';
import '../services/album_service.dart';

class PublicGallery extends StatefulWidget {
  const PublicGallery({super.key});

  static const String route = '/gallery';

  @override
  State<PublicGallery> createState() => _PublicGalleryState();
}

class _PublicGalleryState extends State<PublicGallery> {
  final Future<Album?> album = AlbumService.fetchAlbumByName('gallery', null);
  late Future googleFontsPending = GoogleFonts.pendingFonts();
  int currentImageIndex = 0;
  bool showSlideshow = false;
  final scrollController = ScrollController();
  final focusNode = FocusNode();
  bool ignoreKey = false;

  @override
  void initState() {
    super.initState();

    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
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
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          var imageSize = ImageSizes.medium;
          if (screenWidth > 750) {
            imageSize = ImageSizes.large;
          }
          return KeyboardListener(
            focusNode: focusNode,
            onKeyEvent: (value) {
              if (showSlideshow) return;
              if (ignoreKey) {
                ignoreKey = false;
                return;
              }
              ignoreKey = true;
              if (value.logicalKey == LogicalKeyboardKey.arrowDown) {
                scrollController.animateTo(
                  scrollController.offset + 100,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.linear,
                );
              } else if (value.logicalKey == LogicalKeyboardKey.arrowUp) {
                scrollController.animateTo(
                  scrollController.offset - 100,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.linear,
                );
              }
            },
            child: Stack(
              children: [
                CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [const SizedBox(height: AppScaffold.appBarHeight)],
                      ),
                    ),
                    ImageGallery(
                      album: album,
                      onImageTapped: (index) {
                        setState(() {
                          showSlideshow = true;
                          currentImageIndex = index;
                        });
                      },
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
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: SizedBox(
                    width: screenWidth,
                    height: AppScaffold.appBarHeight,
                    child: CustomAppBar(
                      currentScreen: ScreensEnum.gallery,
                      googleFontsPending: googleFontsPending,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: SizedBox(
                    height: screenHeight,
                    width: screenWidth,
                    child: ImageSlideshow(
                      initialImageIndex: currentImageIndex,
                      isOpen: showSlideshow,
                      album: album,
                      imageSize: imageSize,
                      onDismissed: () {
                        setState(() {
                          showSlideshow = false;
                        });
                        focusNode.requestFocus();
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
