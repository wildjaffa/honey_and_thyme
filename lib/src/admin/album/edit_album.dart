import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:honey_and_thyme/src/admin/album/album_form.dart';
import 'package:honey_and_thyme/src/albums/image_gallery.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/services/album_service.dart';
import 'package:honey_and_thyme/src/services/image_service.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';

import '../../models/album.dart';
import '../../widgets/album_dropdown_search.dart';
import 'image_upload.dart';

class EditAlbum extends StatefulWidget {
  final String albumId;

  static const String route = '/admin/album';

  const EditAlbum({
    super.key,
    required this.albumId,
  });

  @override
  State<EditAlbum> createState() => _EditAlbumState();
}

class _EditAlbumState extends State<EditAlbum> {
  late Future<Album> album = AlbumService.fetchAlbumById(widget.albumId, null);
  Album? selectedOtherAlbum;

  bool editing = false;

  List<String> selectedImages = [];

  void imageSelected(String imageId) async {
    final isShiftPressed =
        HardwareKeyboard.instance.logicalKeysPressed.contains(
              LogicalKeyboardKey.shiftLeft,
            ) ||
            HardwareKeyboard.instance.logicalKeysPressed.contains(
              LogicalKeyboardKey.shiftRight,
            );

    if (isShiftPressed && selectedImages.isNotEmpty) {
      final albumDetails = await album;
      final firstIndex = albumDetails.images!.values!
          .toList()
          .indexWhere((element) => element!.imageId == selectedImages.first);
      final lastIndex = albumDetails.images!.values!
          .toList()
          .indexWhere((element) => element!.imageId == imageId);
      final start = firstIndex < lastIndex ? firstIndex : lastIndex;
      final end = firstIndex < lastIndex ? lastIndex : firstIndex;
      final newSelected = albumDetails.images!.values!
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

  Future<void> addToOtherAlbum() async {
    try {
      if (selectedOtherAlbum == null) {
        return;
      }
      final result = await AlbumService.addImagesToAlbum(
          selectedOtherAlbum!.albumId!, selectedImages);
      SnackBar snackBar;
      if (result) {
        snackBar = SnackBar(
          content: Text('Images added to ${selectedOtherAlbum!.name}'),
        );
      } else {
        snackBar = const SnackBar(
          content: Text('There was a problem adding images to other album'),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        selectedImages = [];
      });
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('Error adding images to other album: $e'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> unlockAlbum() async {
    try {
      final awaitedAlbum = await album;
      final albumResult = await AlbumService.unlockAlbum(awaitedAlbum);
      final snackBar = SnackBar(
        content: Text('Album ${albumResult.name} unlocked'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      refreshAlbum();
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('Error unlocking album: $e'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> refreshAlbum() async {
    album = AlbumService.fetchAlbumById(widget.albumId, null);
    setState(() {
      album = album;
    });
  }

  Future<void> confirmDeleteImages() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Album'),
          content: const Text('Are you sure you want to delete this album?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await deleteSelectedImages();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> scanAlbum() async {
    try {
      final awaitedAlbum = await album;
      final result = await AlbumService.scanAlbum(awaitedAlbum);
      const snackBar = SnackBar(
        content: Text('Album Queued for Scanning successfully'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('Error scanning album: $e'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> deleteSelectedImages() async {
    try {
      final awaitedAlbum = await album;
      for (final imageId in selectedImages) {
        await ImageService.deleteImage(imageId);
      }
      final snackBar = SnackBar(
        content: Text('Images deleted from album ${awaitedAlbum.name}'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        selectedImages = [];
      });
      refreshAlbum();
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('Error deleting images: $e'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> updateCoverPhoto() async {
    try {
      final imageId = selectedImages.first;
      final awaitedAlbum = await album;
      awaitedAlbum.coverImageId = imageId;
      await AlbumService.updateAlbum(awaitedAlbum);
      final snackBar = SnackBar(
        content: Text('Cover photo updated for album ${awaitedAlbum.name}'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        selectedImages = [];
      });
      refreshAlbum();
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('Error updating cover photo: $e'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentScreen: ScreensEnum.admin,
      child: FutureBuilder(
        future: album,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error occurred while loading the album.'),
            );
          }
          final Album album = snapshot.data as Album;
          return editing
              ? Column(
                  children: [
                    AlbumForm(
                        album: album,
                        onAlbumSaved: () {
                          setState(() {
                            editing = false;
                          });
                          refreshAlbum();
                        }),
                    ElevatedButton(
                      onPressed: () => {
                        setState(() {
                          editing = false;
                        })
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                )
              : CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Center(child: Text(album.name!)),
                          Center(child: Text(album.description!)),
                          Center(
                            child: Text(
                                'There are ${album.images!.values!.length} images in this album'),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () => {
                                    setState(() {
                                      editing = true;
                                    })
                                  },
                                  child: const Text('Edit Album'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ImageUpload(
                                  album: album,
                                  onUploadComplete: refreshAlbum,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: scanAlbum,
                                  child: const Text('Scan Album'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AlbumDropdownSearch(
                                  width: 300,
                                  onAlbumSelected: (album) {
                                    setState(() {
                                      selectedOtherAlbum = album;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (album.isLocked == true)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: unlockAlbum,
                                child: const Text('Unlock Album'),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              // width: 1000,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: selectedImages.isEmpty
                                        ? null
                                        : deleteSelectedImages,
                                    icon: const Icon(Icons.delete),
                                  ),
                                  ElevatedButton(
                                    onPressed: selectedImages.length == 1
                                        ? updateCoverPhoto
                                        : null,
                                    child: const Text('Mark as Cover Photo'),
                                  ),
                                  ElevatedButton(
                                    onPressed: selectedImages.isEmpty ||
                                            selectedOtherAlbum == null
                                        ? null
                                        : addToOtherAlbum,
                                    child: const Text('Add to Other Album'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ImageGallery(
                      album: album,
                      onImageSelected: (imageId) {
                        imageSelected(imageId);
                      },
                      selectedImages: selectedImages,
                    ),
                  ],
                );
        },
      ),
    );
  }
}
