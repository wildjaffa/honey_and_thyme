import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:honey_and_thyme/src/admin/admin.dart';
import 'package:honey_and_thyme/src/admin/authenticate.dart';

import '../../models/album.dart';
import '../../models/enums/image_sizes.dart';
import '../../models/enums/screens.dart';
import '../../models/image.dart';
import '../../services/album_service.dart';
import '../../services/image_service.dart';
import '../../services/utils/image_utils.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/back_or_add_buttons.dart';
import '../../widgets/fade_in_image_with_place_holder.dart';
import '../../widgets/honey_input_field.dart';
import '../../widgets/pagination_controls.dart';
import '../../widgets/pagination_state.dart';
import 'album_form.dart';
import 'edit_album.dart';

class AlbumList extends StatefulWidget {
  const AlbumList({super.key});
  static const String route = '/album-list';

  @override
  State<AlbumList> createState() => _AlbumListState();
}

class _AlbumListState extends State<AlbumList> {
  late PaginationState<PaginatedAlbums> _paginationState;
  bool addingAlbum = false;
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _paginationState = PaginationState<PaginatedAlbums>(
      dataFetchCallback: _fetchAlbums,
    );
    _paginationState.loadInitialData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _paginationState.dispose();
    super.dispose();
  }

  Future<PaginatedAlbums?> _fetchAlbums(int page, int pageSize) async {
    return AlbumService.fetchAlbums(
      page: page,
      pageSize: pageSize,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
  }

  void _refreshAlbums() {
    _paginationState.reset();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
        _paginationState.reset();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentScreen: ScreensEnum.admin,
      child: Authenticate(
        child: Center(
          child: Builder(builder: (context) {
            return SizedBox(
              width: 300,
              child: addingAlbum
                  ? AlbumForm(
                      album: Album(),
                      onAlbumSaved: () => setState(() {
                        addingAlbum = false;
                        _refreshAlbums();
                      }),
                    )
                  : ListenableBuilder(
                      listenable: _paginationState,
                      builder: (context, child) {
                        if (_paginationState.isLoading) {
                          return const CircularProgressIndicator();
                        }
                        if (_paginationState.error != null) {
                          return Text('Error: ${_paginationState.error}');
                        }
                        if (_paginationState.data == null) {
                          return const Text('No albums found');
                        }

                        final albumsData = _paginationState.data!;

                        return Column(
                          children: [
                            // Search bar
                            HoneyInputField(
                              initialValue: _searchQuery,
                              label: 'Search Albums',
                              hintText: 'Search by album name',
                              onChanged: _onSearchChanged,
                              startingIcon: const Icon(Icons.search),
                              width: 300,
                              autofocus: true,
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount:
                                    (albumsData.results?.length ?? 0) + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return BackOrAddButtons(
                                      backRoute: AdminView.route,
                                      addText: 'Create New Album',
                                      onAdd: () => setState(() {
                                        addingAlbum = true;
                                      }),
                                    );
                                  }

                                  return AlbumSummary(
                                    album: albumsData.results![index - 1],
                                    refreshAlbum: _refreshAlbums,
                                  );
                                },
                              ),
                            ),
                            // Pagination controls
                            if (albumsData.results?.isNotEmpty == true)
                              PaginationControls<PaginatedAlbums>(
                                paginationState: _paginationState,
                                onUpdate: (paginationState) {
                                  _fetchAlbums(paginationState.pageIndex,
                                      paginationState.pageSize);
                                },
                              ),
                          ],
                        );
                      },
                    ),
            );
          }),
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
        ),
      ),
    );
  }
}
