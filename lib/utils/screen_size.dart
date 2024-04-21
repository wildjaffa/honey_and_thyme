import 'package:flutter/material.dart';

class ScreenSizeUtils {
  static double contentHeight(BuildContext context) {
    return MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        100;
  }
}
