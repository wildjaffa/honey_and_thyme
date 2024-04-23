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
    return Column(children: [
      SizedBox(
        // duration: animationDuration,
        height: 150,
        child: Column(
          children: [
            const SizedBox(
              // duration: animationDuration,
              height: 100,
              child: Center(
                child: Text(
                  'Honey+Thyme',
                  // duration: animationDuration,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 60,
                      fontFamily: 'MarchRough'),
                ),
                //child: const Text('Honey+Thyme')),
              ),
            ),
            Container(
              // duration: animationDuration,
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
                              appBarPercent: 1,
                              route: PricingView.route,
                              title: 'Pricing',
                              isSelected: currentScreen == ScreensEnum.pricing,
                            ),
                            const Spacer(),
                            NavItem(
                              animationDuration: animationDuration,
                              appBarPercent: 1,
                              route: '/albums/kara-and-thomas',
                              title: 'Gallery',
                              isSelected: currentScreen == ScreensEnum.gallery,
                            ),
                            const Spacer(),
                            NavItem(
                              animationDuration: animationDuration,
                              appBarPercent: 1,
                              route: ContactView.route,
                              title: 'Contact',
                              isSelected: currentScreen == ScreensEnum.contact,
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
              // duration: animationDuration,
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
  final double appBarPercent;
  final Duration animationDuration;

  const NavItem(
      {super.key,
      required this.title,
      required this.isSelected,
      required this.route,
      required this.appBarPercent,
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
                fontSize: 24 * widget.appBarPercent,
                color: _hovering ? Constants.goldColor : Colors.black,
              ),
            ),

            Text(
              widget.title,
              style: GoogleFonts.imFellEnglishSc(
                fontSize: 24 * widget.appBarPercent,
                color: widget.isSelected ? Constants.goldColor : Colors.black,
              ),
            ),
            Text(
              ' •',
              style: GoogleFonts.imFellEnglishSc(
                fontSize: 24 * widget.appBarPercent,
                color: _hovering ? Constants.goldColor : Colors.black,
              ),
            ),
            // AnimatedDefaultTextStyle(
            //   style: GoogleFonts.imFellEnglishSc(
            //     fontSize: 24 * widget.appBarPercent,
            //     color: _hovering ? Constants.goldColor : Colors.black,
            //   ),
            //   duration: widget.animationDuration,
            //   child: const Text(
            //     '• ',
            //   ),
            // ),
            // AnimatedDefaultTextStyle(
            //   style: GoogleFonts.imFellEnglishSc(
            //     fontSize: 24 * widget.appBarPercent,
            //     color: widget.isSelected ? Constants.goldColor : Colors.black,
            //   ),
            //   duration: widget.animationDuration,
            //   child: Text(
            //     widget.title,
            //   ),
            // ),
            // AnimatedDefaultTextStyle(
            //   style: GoogleFonts.imFellEnglishSc(
            //     fontSize: 24 * widget.appBarPercent,
            //     color: _hovering ? Constants.goldColor : Colors.black,
            //   ),
            //   duration: widget.animationDuration,
            //   child: const Text(
            //     ' •',
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
