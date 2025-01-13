import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/admin/album/album_list.dart';
import 'package:honey_and_thyme/src/admin/authenticate.dart';
import 'package:honey_and_thyme/src/admin/photo_shoot/photo_shoot_list.dart';
import 'package:honey_and_thyme/src/admin/product/product_list.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';

class AdminView extends StatefulWidget {
  const AdminView({
    super.key,
  });

  static const String route = '/admin';

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentScreen: ScreensEnum.admin,
      child: Authenticate(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              AdminNavigationButton(
                onPressed: () => Navigator.pushNamed(context, AlbumList.route),
                text: 'Albums',
              ),
              AdminNavigationButton(
                onPressed: () =>
                    Navigator.pushNamed(context, PhotoShootList.route),
                text: 'Photo Shoots',
              ),
              AdminNavigationButton(
                onPressed: () =>
                    Navigator.pushNamed(context, ProductList.route),
                text: 'Products',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminNavigationButton extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  const AdminNavigationButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
