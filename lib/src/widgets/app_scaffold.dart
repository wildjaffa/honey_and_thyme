import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/widgets/app_bar.dart';
import 'package:honey_and_thyme/utils/screen_size.dart';

import '../../utils/constants.dart';
import '../models/enums/screens.dart';

class AppScaffold extends StatefulWidget {
  static const appBarHeight = 150.0;

  final Widget child;
  final ScreensEnum currentScreen;
  final bool showAppBar;
  const AppScaffold({
    super.key,
    required this.child,
    required this.currentScreen,
    this.showAppBar = true,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late Future googleFontsPending;

  @override
  void initState() {
    super.initState();
    GoogleFonts.imFellEnglishSc();
    googleFontsPending = GoogleFonts.pendingFonts();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentHeight = ScreenSizeUtils.contentHeight(context);
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: Constants.grayColor,
      body: Column(
        children: [
          if (widget.showAppBar)
            SizedBox(
              height: AppScaffold.appBarHeight,
              child: CustomAppBar(
                currentScreen: widget.currentScreen,
                googleFontsPending: googleFontsPending,
              ),
            ),
          SizedBox(
            width: screenWidth,
            height: widget.showAppBar ? contentHeight : screenHeight,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
