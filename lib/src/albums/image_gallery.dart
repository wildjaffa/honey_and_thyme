import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/album.dart';
import '../models/enums/image_sizes.dart';
import '../services/image_service.dart';
import '../services/utils/image_utils.dart';
import '../widgets/fade_in_image_with_place_holder.dart';

class ImageGallery extends StatelessWidget {
  final Album album;
  final void Function(int)? onImageTapped;
  final void Function(int)? onImageSelected;
  final List<int>? selectedImages;
  const ImageGallery({
    super.key,
    required this.album,
    this.selectedImages,
    this.onImageTapped,
    this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var itemCount = album.images!.values?.length ?? 0;
    if (itemCount == 0) {
      return const Center(
        child: Text('No images found in this album'),
      );
    }
    var crossAxisCount = 2;
    var imageSize = ImageSizes.medium;
    if (screenWidth > 500) {
      crossAxisCount = 3;
    }
    if (screenWidth > 750) {
      crossAxisCount = 4;
      imageSize = ImageSizes.large;
    }
    if (screenWidth > 1000) {
      crossAxisCount = 5;
    }
    final imageWidth = screenWidth / crossAxisCount;
    return SliverMasonryGrid(
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= itemCount) {
            return null;
          }
          final image = album.images!.values![index]!;
          return FadeInImageWithPlaceHolder(
            isSelected: selectedImages?.contains(image.imageId!),
            onSelected: onImageSelected != null
                ? () => {onImageSelected!(image.imageId!)}
                : null,
            onTapped:
                onImageTapped != null ? () => {onImageTapped!(index)} : null,
            imageUrl: ImageService.getImageUrl(
                image.imageId!, imageSize, album.password),
            size: ImageUtils.calculateImageSize(
              imageWidth: imageWidth,
              aspectRatio: image.metaData?.aspectRatio ?? 1,
            ),
          );
        },
      ),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
    );
  }
}
