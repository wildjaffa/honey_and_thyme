import 'package:flutter/material.dart';

const backgroundColor = Color.fromRGBO(217, 217, 217, 1);

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
        backgroundColor: backgroundColor,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: 5,
              color: Colors.black,
            ),
            child
          ],
        ),
      ),
    );
  }
}
