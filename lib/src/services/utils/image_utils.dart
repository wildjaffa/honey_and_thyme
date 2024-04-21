import 'package:flutter/material.dart';

class ImageUtils {
  static Size calculateImageSize({
    required double aspectRatio,
    double? imageWidth,
    double? imageHeight,
  }) {
    if (imageWidth == null && imageHeight == null) {
      throw ArgumentError('Either imageWidth or imageHeight must be provided');
    }
    if (imageWidth != null) {
      final height = imageWidth / aspectRatio;
      return Size(imageWidth, height);
    }
    final width = imageHeight! * aspectRatio;
    return Size(width, imageHeight);
  }
}
