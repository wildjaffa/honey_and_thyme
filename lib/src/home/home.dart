import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:transparent_image/transparent_image.dart';

import '../models/enums/screens.dart';

class Home extends StatelessWidget {
  const Home({
    super.key,
  });

  final List<String> images = const [
    'http://jensennas.local:8568/assets/HomePage/IMG_1636.jpg',
    'http://jensennas.local:8568/assets/HomePage/PXL_20221218_174920383.PORTRAIT.jpg',
    'http://jensennas.local:8568/assets/HomePage/PXL_20231109_195510638.PORTRAIT.ORIGINAL.jpg',
    'http://jensennas.local:8568/assets/HomePage/PXL_20220620_001017270.PORTRAIT.jpg',
    'http://jensennas.local:8568/assets/HomePage/IMG_1832.jpg',
    'http://jensennas.local:8568/assets/HomePage/PXL_20231129_211208106.PORTRAIT.jpg',
    'http://jensennas.local:8568/assets/HomePage/PXL_20231129_211208106.PORTRAIT.jpg'
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentScreen: ScreensEnum.home,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return DesktopView(images: images);
        },
      ),
    );
  }
}

class DesktopView extends StatelessWidget {
  const DesktopView({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 40),
          child: SizedBox(
            height: 300,
            child: Row(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: HomePageImage(
                    height: 150, // 2/3
                    width: 100,
                    imageUrl: images[0],
                    delay: const Duration(seconds: 0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: HomePageImage(
                    height: 300, // 9/16
                    width: 200,
                    imageUrl: images[1],
                    delay: const Duration(seconds: 3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: HomePageImage(
                    height: 200, // 16/9
                    width: 200,
                    imageUrl: images[2],
                    delay: const Duration(seconds: 5),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 200,
            child: Row(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: HomePageImage(
                    height: 200, // 16/9
                    width: 200,
                    imageUrl: images[3],
                    delay: const Duration(seconds: 4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: HomePageImage(
                    height: 200, // 2/3
                    width: 200,
                    imageUrl: images[4],
                    delay: const Duration(seconds: 6),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: HomePageImage(
                    height: 200, // 16/9
                    width: 200,
                    imageUrl: images[5],
                    delay: const Duration(seconds: 2),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HomePageImage extends StatelessWidget {
  final String imageUrl;
  final Duration delay;
  final double height;
  final double width;

  const HomePageImage({
    super.key,
    required this.imageUrl,
    required this.delay,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(child: SizedBox()),
        FutureBuilder(
          future: Future.delayed(delay),
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return FadeInImage.memoryNetwork(
                height: height,
                width: width,
                placeholder: kTransparentImage,
                image: imageUrl,
              );
            } else {
              return SizedBox(height: height, width: width);
            }
          }),
        ),
      ],
    );
  }
}
