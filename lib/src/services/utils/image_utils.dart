import 'package:flutter/material.dart';

class ImageUtils {
  static Size calculateImageSize({
    required double aspectRatio,
    double? imageWidth,
    double? imageHeight,
    double? screenWidth,
    double? screenHeight,
  }) {
    if (imageWidth == null && imageHeight == null) {
      throw ArgumentError('Either imageWidth or imageHeight must be provided');
    }
    if (imageWidth != null &&
        imageHeight != null &&
        screenWidth != null &&
        screenHeight != null) {
      if (screenHeight > screenWidth) {
        var width = screenWidth;
        var height = width / aspectRatio;
        if (height > screenHeight) {
          height = screenHeight;
          width = height * aspectRatio;
        }
        return Size(width, height);
      }
      var height = screenHeight;
      var width = height * aspectRatio;
      if (width > screenWidth) {
        width = screenWidth;
        height = width / aspectRatio;
      }
      return Size(width, height);
    }
    if (imageWidth != null) {
      final height = imageWidth / aspectRatio;
      return Size(imageWidth, height);
    }
    final width = imageHeight! * aspectRatio;
    return Size(width, imageHeight);
  }
}
