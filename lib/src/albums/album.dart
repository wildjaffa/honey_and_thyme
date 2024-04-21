import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/services/album_service.dart';
import 'package:honey_and_thyme/src/widgets/app_bar.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:web/web.dart' as web;

import '../../utils/constants.dart';
import '../../utils/screen_size.dart';
import '../models/album.dart';
import '../models/enums/image_sizes.dart';
import '../models/enums/screens.dart';
import '../services/image_service.dart';
import '../services/utils/image_utils.dart';
import '../widgets/fade_in_image_with_place_holder.dart';

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
  static const double imageWidth = 333;

  final scrollController = ScrollController();

  int passwordAttempts = 0;
  String? password;
  List<int> selectedImages = [];
  double appBarPercent = 0;

  Future<Album?> tryGetAlbum() async {
    final album =
        await AlbumService.fetchAlbumByName(widget.albumName, password);
    if (album == null) {
      passwordAttempts++;
      if (passwordAttempts > 1) {
        const snackBar = SnackBar(
          content: Text('Invalid password'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      return null;
    }
    if (password != null) {
      localStorage.setItem('${widget.albumName}-password', password!);
    }
    return album;
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

  @override
  void initState() {
    super.initState();
    GoogleFonts.imFellEnglishSc();
    googleFontsPending = GoogleFonts.pendingFonts();
    password = localStorage.getItem('${widget.albumName}-password');
    fetchAlbum = tryGetAlbum();
    // scrollController.addListener(() {
    //   if (scrollController.position.pixels > 1000) return;
    //   appBarPercent = scrollController.position.pixels * 0.001;
    //   if (appBarPercent > 1) {
    //     appBarPercent = 1;
    //   }
    //   setState(() {
    //     appBarPercent = appBarPercent;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
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
            // final contentHeight = ScreenSizeUtils.contentHeight(context);
            final screenHeight = MediaQuery.of(context).size.height;
            final coverPhotoId =
                album.coverImageId ?? album.images!.values!.first!.imageId!;
            final crossAxisCount = screenWidth ~/ imageWidth;
            return CustomScrollView(
              controller: scrollController,
              physics: const ScrollPhysics(),
              slivers: [
                SliverList(
                    delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CoverImage(
                      imageUrl: ImageService.getImageUrl(
                          coverPhotoId, ImageSizes.extraLarge),
                      width: screenWidth,
                      height: screenHeight,
                      name: album.name!,
                    ),
                  ),
                ])),
                SliverAppBar(
                  backgroundColor: Constants.grayColor,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 150,
                  pinned: true,
                  floating: false,
                  title: CustomAppBar(
                      currentScreen: ScreensEnum.gallery,
                      googleFontsPending: googleFontsPending),
                ),
                SliverMasonryGrid(
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final image = album.images!.values![index]!;
                      return FadeInImageWithPlaceHolder(
                        isSelected: selectedImages.contains(image.imageId!),
                        onSelected: () => {imageSelected(image.imageId!)},
                        imageUrl: ImageService.getImageUrl(
                            image.imageId!, ImageSizes.medium),
                        size: ImageUtils.calculateImageSize(
                            imageWidth: imageWidth,
                            aspectRatio: image.metaData?.aspectRatio ?? 1),
                      );
                    },
                  ),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
              ],
            );
          }),
    );
  }
}

class CoverImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final String name;

  const CoverImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            fadeInDuration: const Duration(milliseconds: 100),
            image: imageUrl,
            fit: BoxFit.cover,
            width: width,
            height: height,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordForm extends StatelessWidget {
  final void Function() onSubmitted;
  final int passwordAttempts;
  final Future<void> fontLoader;
  final void Function(String) onPasswordChanged;
  final double formWidth;

  const PasswordForm({
    super.key,
    required this.onSubmitted,
    required this.passwordAttempts,
    required this.fontLoader,
    required this.onPasswordChanged,
    required this.formWidth,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fontLoader,
      builder: (context, snapshot) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        child: snapshot.connectionState != ConnectionState.done
            ? const SizedBox(key: ValueKey('loading'))
            : Center(
                key: const ValueKey('password'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 40,
                          top: 20,
                          bottom: 20,
                        ),
                        color: Colors.white,
                        width: formWidth,
                        height: 60,
                        child: Center(
                          child: TextFormField(
                            onChanged: onPasswordChanged,
                            maxLength: 254,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the password';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) => onSubmitted(),
                            decoration: InputDecoration(
                              counterText: '',
                              errorStyle:
                                  const TextStyle(height: 0.1, fontSize: 8),
                              hintText: 'Please enter the password',
                              hintStyle: GoogleFonts.imFellEnglish(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onSubmitted,
                      child: const Text('Unlock'),
                    ),
                    if (passwordAttempts > 3)
                      SizedBox(
                        width: 300,
                        child: Text(
                          'If you are sure you are inputting the password correctly, '
                          'it is possible that the album has been locked for your protection. '
                          'Please contact us for more information.',
                          style: GoogleFonts.imFellEnglish(
                            color: Colors.red,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
