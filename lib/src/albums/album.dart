import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/albums/image_gallery.dart';
import 'package:honey_and_thyme/src/albums/image_slideshow.dart';
import 'package:honey_and_thyme/src/models/enums/download_image_sizes.dart';
import 'package:honey_and_thyme/src/widgets/stack_modal.dart';
import 'package:honey_and_thyme/src/services/album_service.dart';
import 'package:honey_and_thyme/src/widgets/app_bar.dart';
import 'package:honey_and_thyme/src/widgets/app_footer.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:signalr_core/signalr_core.dart' as signalR;
import 'package:transparent_image/transparent_image.dart';
import 'package:badges/badges.dart' as badges;
import 'package:web/web.dart' as web;

import '../../utils/constants.dart';
import '../models/album.dart';
import '../models/enums/image_sizes.dart';
import '../models/enums/screens.dart';
import '../services/api_service.dart';
import '../services/image_service.dart';
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

  int passwordAttempts = 0;
  String? password;
  List<String> selectedImages = [];
  double appBarPercent = 0;
  bool showSlideShow = false;
  bool scrolled = false;
  bool passwordInputVisible = false;
  bool isLoading = false;
  bool qualitySelectorIsOpen = false;
  String? downloadUrl;
  int currentImageIndex = 0;
  DownloadImageSizes selectedDownloadSize = DownloadImageSizes.medium;
  final focusNode = FocusNode();
  bool ignoreKey = false;
  double? percentComplete;
  signalR.HubConnection? hubConnection;

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

  Future<void> downloadSelectedImages(List<String> selected) async {
    setState(() {
      qualitySelectorIsOpen = false;
      isLoading = true;
    });

    final connection = signalR.HubConnectionBuilder()
        .withUrl(
          ApiService.getUri(ApiService.url, 'imageDownloadHub').toString(),
        )
        .build();
    await connection.start();
    final connectionId = connection.connectionId;
    if (connectionId == null) {
      setState(() {
        isLoading = false;
      });
      const snackBar = SnackBar(
        content: Text(
            'There was an error starting the download. Please try again later.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    connection.on('ReceiveImageDownloadProgress', updateImageDownloadProgress);

    final album = await fetchAlbum;
    final startedSuccessfully = await ImageService.startImageDownloadZip(
        selected, selectedDownloadSize, album!.password, connectionId);
    if (startedSuccessfully) {
      hubConnection = connection;
      return;
    }
    connection.stop();
    setState(() {
      isLoading = false;
    });
    const snackBar = SnackBar(
      content: Text(
          'There was an error starting the download. Please try again later.'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void updateImageDownloadProgress(dynamic arguments) {
    final double progressPercentage = arguments[0]["percentComplete"];
    final url = arguments[0]["url"];
    setState(() {
      percentComplete = progressPercentage;
    });
    if (progressPercentage < 100) {
      return;
    }
    setState(() {
      isLoading = false;
      downloadUrl = url;
      percentComplete = null;
    });
    hubConnection?.stop();
    web.window.open(url, 'Download Images');
  }

  void imageSelected(String imageId) async {
    final isShiftPressed =
        HardwareKeyboard.instance.logicalKeysPressed.contains(
              LogicalKeyboardKey.shiftLeft,
            ) ||
            HardwareKeyboard.instance.logicalKeysPressed.contains(
              LogicalKeyboardKey.shiftRight,
            );

    if (isShiftPressed && selectedImages.isNotEmpty) {
      final album = await fetchAlbum;
      final firstIndex = album!.images!.values!
          .toList()
          .indexWhere((element) => element!.imageId == selectedImages.first);
      final lastIndex = album.images!.values!
          .toList()
          .indexWhere((element) => element!.imageId == imageId);
      final start = firstIndex < lastIndex ? firstIndex : lastIndex;
      final end = firstIndex < lastIndex ? lastIndex : firstIndex;
      final newSelected = album.images!.values!
          .toList()
          .sublist(start, end + 1)
          .map((e) => e!.imageId!)
          .toList();
      for (final newImage in newSelected) {
        if (!selectedImages.contains(newImage)) {
          selectedImages.add(newImage);
        }
      }
      setState(() {
        selectedImages = selectedImages;
      });
      return;
    }
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
      showSlideShow = true;
      currentImageIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
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
    scrollController.animateTo(MediaQuery.sizeOf(context).height - 200,
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
          final screenWidth = MediaQuery.sizeOf(context).width;
          final screenHeight = MediaQuery.sizeOf(context).height;
          final coverPhotoId =
              album.coverImageId ?? album.images!.values!.first!.imageId!;
          var imageSize = ImageSizes.large;
          return KeyboardListener(
            focusNode: focusNode,
            onKeyEvent: (value) {
              if (showSlideShow || isLoading || qualitySelectorIsOpen) return;
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
                  physics: const ScrollPhysics(),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: CoverImage(
                              imageUrl: ImageService.getImageUrl(coverPhotoId,
                                  ImageSizes.extraLarge, album.password),
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
                      onImageTapped: imageTapped,
                      onImageSelected: imageSelected,
                    ),
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
                                              qualitySelectorIsOpen = true;
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
                                              qualitySelectorIsOpen = true;
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
                  initialImageIndex: currentImageIndex,
                  isOpen: showSlideShow,
                  album: album,
                  imageSize: imageSize,
                  onDismissed: () {
                    setState(() {
                      showSlideShow = false;
                    });
                    focusNode.requestFocus();
                  },
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    width: screenWidth,
                    height: screenHeight,
                    child: Center(
                      child: SizedBox(
                        height: 200,
                        width: .8 * screenWidth,
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            if (percentComplete != null) ...[
                              const SizedBox(height: 20),
                              LinearProgressIndicator(
                                value: percentComplete! / 100,
                                semanticsLabel: 'Preparing download',
                                semanticsValue: '$percentComplete%',
                              ),
                              Text(
                                'Preparing your images for download, please do not refresh your page or leave...',
                                style: GoogleFonts.imFellEnglish(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                if (qualitySelectorIsOpen || downloadUrl != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        qualitySelectorIsOpen = false;
                        downloadUrl = null;
                      });
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      width: screenWidth,
                      height: screenHeight,
                    ),
                  ),
                StackModal(
                  isOpen: qualitySelectorIsOpen,
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
                                qualitySelectorIsOpen = false;
                              });
                            },
                            child: Text('Cancel',
                                style: GoogleFonts.imFellEnglish()),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: startDownload,
                            child: Text(
                              'Download',
                              style: GoogleFonts.imFellEnglish(),
                            ),
                          ),
                          const Spacer(),
                        ],
                      )
                    ],
                  ),
                ),
                StackModal(
                  isOpen: downloadUrl != null,
                  child: Center(
                    child: Container(
                      height: 200,
                      width: 200,
                      child: Column(
                        children: [
                          Text(
                            'Your download should start automatically, if it does not, please tap the button below to start the download.',
                            style: GoogleFonts.imFellEnglish(
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              child: const Text('Download'),
                              onLongPress: () {
                                Clipboard.setData(
                                    ClipboardData(text: downloadUrl!));
                                const snackBar = SnackBar(
                                  content:
                                      Text('Download link copied to clipboard'),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              },
                              onPressed: () {
                                web.window
                                    .open(downloadUrl!, 'Download Images');
                                setState(() {
                                  downloadUrl = null;
                                });
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                downloadUrl = null;
                              });
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
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
