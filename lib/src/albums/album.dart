import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/albums/image_gallery.dart';
import 'package:honey_and_thyme/src/albums/image_slideshow.dart';
import 'package:honey_and_thyme/src/models/enums/download_image_sizes.dart';
import 'package:honey_and_thyme/src/services/album_service.dart';
import 'package:honey_and_thyme/src/widgets/app_bar.dart';
import 'package:honey_and_thyme/src/widgets/app_footer.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:badges/badges.dart' as badges;
import 'package:web/web.dart' as web;

import '../../utils/constants.dart';
import '../models/album.dart';
import '../models/enums/image_sizes.dart';
import '../models/enums/screens.dart';
import '../services/image_service.dart';
import '../services/utils/image_utils.dart';
import '../widgets/fade_in_image_with_place_holder.dart';
import 'password_form.dart';

class AlbumView extends StatefulWidget {
  final String albumName;
  const AlbumView({
    super.key,
    required this.albumName,
  });

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  web.Storage localStorage = web.window.localStorage;

  late Future<Album?> fetchAlbum;
  late Future googleFontsPending;

  static const formWidth = 300.0;

  final scrollController = ScrollController();
  final carouselController = CarouselController();

  int passwordAttempts = 0;
  String? password;
  List<int> selectedImages = [];
  double appBarPercent = 0;
  int? slideShowImageIndex;
  bool scrolled = false;
  bool passwordInputVisible = false;
  bool isLoading = false;
  bool modalIsOpen = false;
  DownloadImageSizes selectedDownloadSize = DownloadImageSizes.medium;

  Future<Album?> tryGetAlbum() async {
    final album =
        await AlbumService.fetchAlbumByName(widget.albumName, password);
    if (album == null) {
      setState(() {
        passwordInputVisible = true;
      });
      passwordAttempts++;
      if (passwordAttempts > 1) {
        const snackBar = SnackBar(
          content: Text('Invalid password'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      return null;
    }
    setState(() {
      passwordInputVisible = false;
    });
    if (password != null) {
      localStorage.setItem('${widget.albumName}-password', password!);
    }
    return album;
  }

  Future<void> startDownload() async {
    if (selectedImages.isEmpty) {
      downloadAlbum();
      return;
    }
    await downloadSelected();
  }

  Future<void> downloadAlbum() async {
    final selected =
        (await fetchAlbum)!.images!.values!.map((e) => e!.imageId!).toList();

    await downloadSelectedImages(selected);
  }

  Future<void> downloadSelected() async {
    await downloadSelectedImages(selectedImages);
    setState(() {
      selectedImages = [];
    });
  }

  Future<void> downloadSelectedImages(List<int> selected) async {
    setState(() {
      modalIsOpen = false;
      isLoading = true;
    });
    final url = await ImageService.getImageDownloadUrl(
        selected, selectedDownloadSize, password);
    setState(() {
      isLoading = false;
    });
    web.window.open(url.toString(), 'Download Images');
  }

  void imageSelected(int imageId) {
    if (selectedImages.contains(imageId)) {
      selectedImages.remove(imageId);
    } else {
      selectedImages.add(imageId);
    }
    setState(() {
      selectedImages = selectedImages;
    });
  }

  void imageTapped(int index) {
    setState(() {
      slideShowImageIndex = index;
    });
    carouselController.jumpToPage(index);
  }

  @override
  void initState() {
    super.initState();
    GoogleFonts.imFellEnglishSc();
    googleFontsPending = GoogleFonts.pendingFonts();
    password = localStorage.getItem('${widget.albumName}-password');
    fetchAlbum = tryGetAlbum();
    scrollController.addListener(() {
      if (scrollController.position.pixels > 100 && !scrolled) {
        setState(() {
          scrolled = true;
        });
      }
      if (scrollController.position.pixels == 0 && scrolled) {
        setState(() {
          scrolled = false;
        });
      }
    });
  }

  void scrollPastCoverImage(BuildContext context) {
    scrollController.animateTo(MediaQuery.of(context).size.height - 200,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: passwordInputVisible,
      currentScreen: ScreensEnum.gallery,
      child: FutureBuilder(
          future: fetchAlbum,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.data == null) {
              return PasswordForm(
                onSubmitted: () {
                  setState(() {
                    fetchAlbum = tryGetAlbum();
                  });
                },
                passwordAttempts: passwordAttempts,
                fontLoader: googleFontsPending,
                onPasswordChanged: (value) {
                  password = value;
                },
                formWidth: formWidth,
              );
            }
            final Album album = snapshot.data as Album;
            var itemCount = album.images!.values?.length ?? 0;
            if (itemCount == 0) {
              return const Center(
                child: Text('No images found in this album'),
              );
            }
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final coverPhotoId =
                album.coverImageId ?? album.images!.values!.first!.imageId!;
            var imageSize = ImageSizes.medium;
            if (screenWidth > 750) {
              imageSize = ImageSizes.large;
            }
            return Stack(
              children: [
                CustomScrollView(
                  controller: scrollController,
                  physics: const ScrollPhysics(),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: CoverImage(
                              imageUrl: ImageService.getImageUrl(coverPhotoId,
                                  ImageSizes.extraLarge, password),
                              width: screenWidth,
                              height: screenHeight,
                              name: album.name!,
                              onIconTap: () => scrollPastCoverImage(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ImageGallery(
                      album: album,
                      selectedImages: selectedImages,
                      password: password,
                      onImageTapped: imageTapped,
                      onImageSelected: imageSelected,
                    ),
                    // SliverMasonryGrid(
                    //   gridDelegate:
                    //       SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: crossAxisCount,
                    //   ),
                    //   delegate: SliverChildBuilderDelegate(
                    //     (context, index) {
                    //       if (index >= itemCount) {
                    //         return null;
                    //       }
                    //       final image = album.images!.values![index]!;
                    //       return FadeInImageWithPlaceHolder(
                    //         isSelected: selectedImages.contains(image.imageId!),
                    //         onSelected: () => {imageSelected(image.imageId!)},
                    //         onTapped: () => {imageTapped(index)},
                    //         imageUrl: ImageService.getImageUrl(
                    //             image.imageId!, imageSize, password),
                    //         size: ImageUtils.calculateImageSize(
                    //             imageWidth: imageWidth,
                    //             aspectRatio: image.metaData?.aspectRatio ?? 1),
                    //       );
                    //     },
                    //   ),
                    //   mainAxisSpacing: 4,
                    //   crossAxisSpacing: 4,
                    // ),
                    SliverList(
                      delegate: SliverChildListDelegate([const AppFooter()]),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: AnimatedOpacity(
                    opacity: scrolled ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      color: Constants.grayColor,
                      width: screenWidth,
                      height: 190,
                      child: Column(
                        children: [
                          CustomAppBar(
                              currentScreen: ScreensEnum.gallery,
                              googleFontsPending: googleFontsPending),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (child, animation) =>
                                      ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                  child: selectedImages.isNotEmpty
                                      ? IconButton(
                                          key:
                                              const ValueKey('download-images'),
                                          onPressed: () {
                                            setState(() {
                                              modalIsOpen = true;
                                            });
                                          },
                                          icon: badges.Badge(
                                            badgeAnimation: const badges
                                                .BadgeAnimation.scale(
                                              animationDuration:
                                                  Duration(milliseconds: 250),
                                            ),
                                            badgeStyle: const badges.BadgeStyle(
                                              // padding: EdgeInsets.all(3),
                                              badgeColor: Constants.goldColor,
                                            ),
                                            position:
                                                badges.BadgePosition.topEnd(
                                              top: -15,
                                              end: -10,
                                            ),
                                            badgeContent: Text(
                                              selectedImages.length.toString(),
                                            ),
                                            child: const Icon(Icons.photo),
                                          ))
                                      : IconButton(
                                          key: const ValueKey('download-album'),
                                          onPressed: () {
                                            setState(() {
                                              modalIsOpen = true;
                                            });
                                          },
                                          icon: const Icon(Icons.download),
                                        ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                ImageSlideshow(
                  carouselController: carouselController,
                  slideShowImageIndex: slideShowImageIndex,
                  album: album,
                  password: password,
                  imageSize: imageSize,
                  onDismissed: () {
                    setState(() {
                      slideShowImageIndex = null;
                    });
                  },
                  onPreviousTapped: () {
                    if (slideShowImageIndex == 0) {
                      return;
                    }
                    setState(() {
                      slideShowImageIndex = slideShowImageIndex! - 1;
                    });
                    carouselController.previousPage();
                  },
                  onNextTapped: () {
                    if (slideShowImageIndex == album.images!.values!.length) {
                      return;
                    }
                    setState(() {
                      slideShowImageIndex = slideShowImageIndex! + 1;
                    });
                    carouselController.nextPage();
                  },
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    width: screenWidth,
                    height: screenHeight,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (modalIsOpen)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        modalIsOpen = false;
                      });
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      width: screenWidth,
                      height: screenHeight,
                    ),
                  ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.decelerate,
                  top: modalIsOpen ? (screenHeight - 300) / 2 : screenHeight,
                  left: (screenWidth - 300) / 2,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 5,
                          )
                        ]),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Downloaded Image Size',
                            style: GoogleFonts.imFellEnglish(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView(
                            children: [
                              ListTile(
                                selected: selectedDownloadSize ==
                                    DownloadImageSizes.medium,
                                tileColor: Constants.grayColor,
                                // selectedColor: Constants.pinkColor,
                                title: Text(
                                  'Medium Quality',
                                  style: GoogleFonts.imFellEnglish(
                                    fontSize: 16,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedDownloadSize =
                                        DownloadImageSizes.medium;
                                  });
                                },
                              ),
                              ListTile(
                                selected: selectedDownloadSize ==
                                    DownloadImageSizes.extraLarge,
                                title: Text(
                                  'High Quality',
                                  style: GoogleFonts.imFellEnglish(
                                    fontSize: 16,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedDownloadSize =
                                        DownloadImageSizes.extraLarge;
                                  });
                                },
                              ),
                              ListTile(
                                selected: selectedDownloadSize ==
                                    DownloadImageSizes.fullRes,
                                title: Text(
                                  'Original Quality',
                                  style: GoogleFonts.imFellEnglish(
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  'Warning: Large file size, may take longer to download. Please be patient and ensure you have a stable internet connection.',
                                  style: GoogleFonts.imFellEnglish(
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedDownloadSize =
                                        DownloadImageSizes.fullRes;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  modalIsOpen = false;
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: startDownload,
                              child: const Text('Download'),
                            ),
                            const Spacer(),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }
}

class CoverImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;
  final String name;
  final void Function()? onIconTap;

  const CoverImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.name,
    this.onIconTap,
  });

  @override
  State<CoverImage> createState() => _CoverImageState();
}

class _CoverImageState extends State<CoverImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController buttonAnimationController =
      AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: this,
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            fadeInDuration: const Duration(milliseconds: 100),
            image: widget.imageUrl,
            fit: BoxFit.cover,
            width: widget.width,
            height: widget.height,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Text(
              widget.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontFamily: 'MarchRough',
              ),
            ),
          ),
          AnimatedBuilder(
            animation: buttonAnimationController,
            builder: (context, child) => Positioned(
              bottom: 20 + buttonAnimationController.value * 20,
              right: 20,
              child: IconButton(
                iconSize: 30,
                icon: const Icon(Icons.arrow_downward, color: Colors.white),
                color: Constants.pinkColor,
                onPressed: widget.onIconTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
