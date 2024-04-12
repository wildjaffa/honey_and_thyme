import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/pricing/pricing.dart';

import '../../utils/constants.dart';
import '../models/enums/screens.dart';

class AppScaffold extends StatefulWidget {
  final Widget child;
  final ScreensEnum currentScreen;
  const AppScaffold({
    super.key,
    required this.child,
    required this.currentScreen,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late Future googleFontsPending;

  double separatorHeight = 4;

  @override
  void initState() {
    super.initState();
    GoogleFonts.imFellEnglishSc();
    googleFontsPending = GoogleFonts.pendingFonts();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 100,
        title: const Text(
          'Honey+Thyme',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        backgroundColor: Constants.backgroundColor,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Constants.backgroundColor,
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Column(
                children: [
                  Container(
                    width: screenWidth,
                    height: separatorHeight,
                    color: Constants.goldColor,
                  ),
                  FutureBuilder(
                    future: googleFontsPending,
                    builder: (context, snapshot) {
                      return AnimatedSwitcher(
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        duration: const Duration(milliseconds: 250),
                        child: snapshot.connectionState == ConnectionState.done
                            ? Row(
                                key: const ValueKey('nav'),
                                children: [
                                  const Spacer(),
                                  NavItem(
                                    route: PricingView.route,
                                    title: 'Pricing',
                                    isSelected: widget.currentScreen ==
                                        ScreensEnum.pricing,
                                  ),
                                  const Spacer(),
                                  NavItem(
                                    route: PricingView.route,
                                    title: 'Gallery',
                                    isSelected: widget.currentScreen ==
                                        ScreensEnum.gallery,
                                  ),
                                  const Spacer(),
                                  NavItem(
                                    route: PricingView.route,
                                    title: 'Contact',
                                    isSelected: widget.currentScreen ==
                                        ScreensEnum.contact,
                                  ),
                                  const Spacer(),
                                ],
                              )
                            : const SizedBox(
                                key: ValueKey('loading'),
                                child: Text(
                                  ' ',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                      );
                    },
                  ),
                  Container(
                    width: screenWidth,
                    height: separatorHeight,
                    color: Constants.goldColor,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: screenWidth,
              height: screenHeight - 100,
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem extends StatefulWidget {
  final String title;
  final bool isSelected;
  final String route;

  const NavItem({
    super.key,
    required this.title,
    required this.isSelected,
    required this.route,
  });

  @override
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(
              context, widget.route, (route) => route.isFirst);
        },
        child: Row(
          children: [
            Text(
              '• ',
              style: GoogleFonts.imFellEnglishSc(
                fontSize: 24,
                color: _hovering ? Constants.goldColor : Colors.black,
              ),
            ),
            Text(
              widget.title,
              style: GoogleFonts.imFellEnglishSc(
                fontSize: 24,
                color: widget.isSelected ? Constants.goldColor : Colors.black,
              ),
            ),
            Text(
              ' •',
              style: GoogleFonts.imFellEnglishSc(
                fontSize: 24,
                color: _hovering ? Constants.goldColor : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
