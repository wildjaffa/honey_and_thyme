import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';
import '../contact/contact.dart';
import '../models/enums/screens.dart';
import '../pricing/pricing.dart';

class CustomAppBar extends StatelessWidget {
  final ScreensEnum currentScreen;
  final Future googleFontsPending;
  const CustomAppBar({
    super.key,
    required this.currentScreen,
    required this.googleFontsPending,
  });

  static const double separatorHeight = 4;
  static const Duration animationDuration = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double fontSizeMultiplier = screenWidth >= 500 ? 1 : 0.75;
    return Column(children: [
      SizedBox(
        height: 150,
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: Center(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (route) => route.isFirst);
                    },
                    child: Text(
                      'Honey+Thyme',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth >= 500 ? 60 : 40,
                          fontFamily: 'MarchRough'),
                    ),
                  ),
                ),
              ),
            ),
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
                  duration: animationDuration,
                  child: snapshot.connectionState == ConnectionState.done
                      ? Row(
                          key: const ValueKey('nav'),
                          children: [
                            const Spacer(),
                            NavItem(
                              animationDuration: animationDuration,
                              fontSizeMultiplier: fontSizeMultiplier,
                              route: PricingView.route,
                              title: 'Pricing',
                              isSelected: currentScreen == ScreensEnum.pricing,
                            ),
                            const Spacer(),
                            NavItem(
                              animationDuration: animationDuration,
                              fontSizeMultiplier: fontSizeMultiplier,
                              route: '/albums/kara-and-thomas',
                              title: 'Gallery',
                              isSelected: currentScreen == ScreensEnum.gallery,
                            ),
                            const Spacer(),
                            NavItem(
                              animationDuration: animationDuration,
                              fontSizeMultiplier: fontSizeMultiplier,
                              route: ContactView.route,
                              title: 'Contact',
                              isSelected: currentScreen == ScreensEnum.contact,
                            ),
                            const Spacer(),
                          ],
                        )
                      : SizedBox(
                          key: const ValueKey('loading'),
                          child: Text(
                            ' ',
                            style: TextStyle(fontSize: 24 * fontSizeMultiplier),
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
      )
    ]);
  }
}

class NavItem extends StatefulWidget {
  final String title;
  final bool isSelected;
  final String route;
  final double fontSizeMultiplier;
  final Duration animationDuration;

  const NavItem(
      {super.key,
      required this.title,
      required this.isSelected,
      required this.route,
      required this.fontSizeMultiplier,
      required this.animationDuration});

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
                fontSize: 24 * widget.fontSizeMultiplier,
                color: _hovering ? Constants.goldColor : Colors.black,
              ),
            ),
            Text(
              widget.title,
              style: GoogleFonts.imFellEnglishSc(
                fontSize: 24 * widget.fontSizeMultiplier,
                color: widget.isSelected ? Constants.goldColor : Colors.black,
              ),
            ),
            Text(
              ' •',
              style: GoogleFonts.imFellEnglishSc(
                fontSize: 24 * widget.fontSizeMultiplier,
                color: _hovering ? Constants.goldColor : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
