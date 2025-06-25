import 'dart:async';
import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/models/album.dart';
import 'package:honey_and_thyme/src/services/album_service.dart';

class AlbumDropdownSearch extends StatefulWidget {
  final Album? selectedAlbum;
  final Function(Album?) onAlbumSelected;
  final String? label;
  final String? hint;
  final bool enabled;
  final String? errorText;
  final bool showClearButton;
  final int pageSize;
  final Duration debounceDelay;
  final double? width;

  const AlbumDropdownSearch({
    super.key,
    this.selectedAlbum,
    required this.onAlbumSelected,
    this.label,
    this.hint,
    this.enabled = true,
    this.errorText,
    this.showClearButton = true,
    this.pageSize = 20,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.width,
  });

  @override
  State<AlbumDropdownSearch> createState() => _AlbumDropdownSearchState();
}

class _AlbumDropdownSearchState extends State<AlbumDropdownSearch> {
  final TextEditingController _searchController = TextEditingController();
  final SearchController _searchAnchorController = SearchController();
  List<Album> _albums = [];
  bool _isLoading = false;
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.selectedAlbum?.name != null) {
      _searchController.text = widget.selectedAlbum!.name!;
    }
    _loadAlbums();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAnchorController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAlbums() async {
    print('loadAlbums');
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AlbumService.fetchAlbums(
        page: 0,
        pageSize: widget.pageSize,
        search: _searchQuery,
      );

      if (result != null && result.results != null) {
        setState(() {
          _albums = result.results!;
        });
      }
    } catch (e) {
      // Handle error silently or show a snackbar

      setState(() {
        _albums = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    // Cancel the previous timer
    _debounceTimer?.cancel();

    // Set the search query immediately for UI responsiveness
    setState(() {
      _searchQuery = query;
    });

    // Open the search view if it's not already open
    if (!_searchAnchorController.isOpen) {
      _searchAnchorController.openView();
    }

    // Start a new timer for debounced search
    _debounceTimer = Timer(widget.debounceDelay, () {
      _loadAlbums();
    });
  }

  void _onAlbumSelected(Album album) {
    setState(() {
      _searchController.text = album.name ?? '';
    });
    _searchAnchorController.closeView(_searchController.text);
    widget.onAlbumSelected(album);
  }

  void _clearSelection() {
    _searchController.clear();
    widget.onAlbumSelected(null);
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                widget.label!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          SearchAnchor(
            searchController: _searchAnchorController,
            isFullScreen: false,
            viewHintText: widget.hint ?? 'Search albums...',
            viewLeading: widget.showClearButton && widget.selectedAlbum != null
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _clearSelection,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                : null,
            viewOnChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            suggestionsBuilder: (context, controller) async {
              final query = controller.text.toLowerCase();

              // If we're loading, show loading state
              if (_isLoading) {
                return [
                  const ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('Loading...'),
                  ),
                ];
              }

              // Filter albums based on current query
              final filtered = _albums
                  .where((album) =>
                      (album.name?.toLowerCase().contains(query) ?? false) ||
                      (album.description?.toLowerCase().contains(query) ??
                          false))
                  .toList();

              if (filtered.isEmpty) {
                return [
                  const ListTile(
                    title: Text(
                      'No albums found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ];
              }

              return filtered.map((album) {
                return ListTile(
                  title: Text(
                    album.name ?? 'Untitled Album',
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle:
                      album.description != null && album.description!.isNotEmpty
                          ? Text(
                              album.description!,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                  dense: true,
                  onTap: () => _onAlbumSelected(album),
                );
              }).toList();
            },
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.errorText != null
                        ? Colors.red
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: controller,
                  enabled: widget.enabled,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: widget.hint ?? 'Search albums...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    suffixIcon:
                        widget.showClearButton && widget.selectedAlbum != null
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: _clearSelection,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              )
                            : const Icon(Icons.search),
                  ),
                ),
              );
            },
          ),
          if (widget.errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                widget.errorText!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
