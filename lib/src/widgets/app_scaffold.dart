import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({
    super.key,
    required this.child,
  });

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
                    height: 5,
                    color: Constants.goldColor,
                  ),
                  const Row(children: [
                    Spacer(),
                    NavItem(title: 'Pricing'),
                    Spacer(),
                    NavItem(title: 'Gallery'),
                    Spacer(),
                    NavItem(title: 'Contact'),
                    Spacer(),
                  ]),
                  Container(
                    width: screenWidth,
                    height: 5,
                    color: Constants.goldColor,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: screenWidth,
              height: screenHeight - 100,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem extends StatefulWidget {
  final String title;
  const NavItem({super.key, required this.title});

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
              color: Colors.black,
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
    );
  }
}
