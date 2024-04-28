import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:honey_and_thyme/src/admin/album/album_form.dart';
import 'package:honey_and_thyme/src/admin/album/edit_album.dart';
import 'package:honey_and_thyme/src/admin/login_form.dart';
import 'package:honey_and_thyme/src/models/album.dart';
import 'package:honey_and_thyme/src/models/enums/image_sizes.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/services/album_service.dart';
import 'package:honey_and_thyme/src/services/image_service.dart';
import 'package:honey_and_thyme/src/services/utils/image_utils.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';

import '../models/image.dart';
import '../widgets/fade_in_image_with_place_holder.dart';

class AdminView extends StatefulWidget {
  const AdminView({
    super.key,
  });

  static const String route = '/admin';

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  Future<List<Album>> albums = AlbumService.fetchAlbums();

  bool addingAlbum = false;
  late bool isAuthenticated;

  @override
  void initState() {
    isAuthenticated = FirebaseAuth.instance.currentUser != null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentScreen: ScreensEnum.admin,
      child: Center(
        child: isAuthenticated
            ? SizedBox(
                width: 300,
                child: addingAlbum
                    ? AlbumForm(
                        album: Album(),
                        onAlbumSaved: () => setState(() {
                          addingAlbum = false;
                          albums = AlbumService.fetchAlbums();
                        }),
                      )
                    : FutureBuilder(
                        future: albums,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          return ListView.builder(
                            itemCount: snapshot.data!.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    child: const Text('Create New Album'),
                                    onPressed: () => setState(() {
                                      addingAlbum = true;
                                    }),
                                  ),
                                );
                              }

                              return AlbumSummary(
                                album: snapshot.data![index - 1],
                                refreshAlbum: () => setState(() {
                                  albums = AlbumService.fetchAlbums();
                                }),
                              );
                            },
                          );
                        },
                      ),
              )
            : LoginForm(
                onSignIn: () {
                  setState(() {
                    isAuthenticated = true;
                    albums = AlbumService.fetchAlbums();
                  });
                },
              ),
      ),
    );
  }
}

class AlbumSummary extends StatefulWidget {
  final Album album;
  final void Function() refreshAlbum;
  const AlbumSummary({
    super.key,
    required this.album,
    required this.refreshAlbum,
  });

  @override
  State<AlbumSummary> createState() => _AlbumSummaryState();
}

class _AlbumSummaryState extends State<AlbumSummary> {
  Future<ImageData?>? coverImage;

  Future<void> unlockAlbum() async {
    try {
      final awaitedAlbum = widget.album;
      final albumResult = await AlbumService.unlockAlbum(awaitedAlbum);
      final snackBar = SnackBar(
        content: Text('Album ${albumResult.name} unlocked'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      widget.refreshAlbum();
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('Error unlocking album: $e'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void copyShareData() {
    final url = '${Uri.base.origin}/#/albums/${widget.album.urlName}';
    var text = 'Check out your album at $url';
    if (widget.album.password != null) {
      text += ' and use password ${widget.album.password}';
    }
    Clipboard.setData(ClipboardData(text: text));
    const snackBar = SnackBar(
      content: Text('Album linked saved to clipboard'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    if (widget.album.coverImageId != null) {
      coverImage = ImageService.getImageData(widget.album.coverImageId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(
                '${EditAlbum.route}?albumId=${widget.album.albumId}',
                arguments: widget.album,
              ),
          child: Row(
            children: [
              if (widget.album.coverImageId != null)
                FutureBuilder(
                  future: coverImage,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError ||
                        snapshot.data?.metaData?.aspectRatio == null) {
                      return const Icon(Icons.error);
                    }

                    return FadeInImageWithPlaceHolder(
                      isSelected: false,
                      imageUrl: ImageService.getImageUrl(
                          widget.album.coverImageId!,
                          ImageSizes.medium,
                          widget.album.password),
                      size: ImageUtils.calculateImageSize(
                          imageWidth: 50,
                          imageHeight: 50,
                          aspectRatio: snapshot.data!.metaData!.aspectRatio!),
                    );
                  },
                ),
              if (widget.album.coverImageId == null)
                const SizedBox(
                  width: 50,
                  height: 50,
                ),
              SizedBox(
                width: 190,
                child: Column(
                  children: [
                    Text(
                      widget.album.name!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      widget.album.description!,
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 60,
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: IconButton(
                        onPressed:
                            widget.album.isLocked == true ? unlockAlbum : null,
                        icon: Icon(widget.album.isLocked == true
                            ? Icons.lock
                            : Icons.lock_open),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                      child: IconButton(
                        onPressed: copyShareData,
                        icon: const Icon(Icons.share),
                      ),
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
