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
                    NavItem(title: '• Pricing •'),
                    Spacer(),
                    NavItem(title: '• Gallery •'),
                    Spacer(),
                    NavItem(title: '• Contact •'),
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

class NavItem extends StatelessWidget {
  final String title;
  const NavItem({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text(
        title,
        style: GoogleFonts.imFellEnglishSc(
          fontSize: 24,
          color: Colors.black,
        ),
      ),
    );
  }
}
