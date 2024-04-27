import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  static const footerHeight = 300.0;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 50, top: 50),
      child: Center(
        child: Image(
          image: AssetImage('assets/images/logo.png'),
          width: 300,
          height: footerHeight,
        ),
      ),
    );
  }
}
