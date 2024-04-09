import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';

class Home extends StatelessWidget {
  const Home({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      child: Column(
        children: [
          Text('Welcome to Honey+Thyme!'),
          Text('Your one-stop shop for all things honey and thyme.'),
        ],
      ),
    );
  }
}
