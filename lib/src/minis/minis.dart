import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/widgets/app_footer.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:transparent_image/transparent_image.dart';

import '../contact/contact_form.dart';
import '../models/album.dart';
import '../models/enums/image_sizes.dart';
import '../models/enums/screens.dart';
import '../services/album_service.dart';
import '../services/image_service.dart';

class MinisView extends StatefulWidget {
  static const String route = '/minis';

  const MinisView({super.key});

  @override
  State<MinisView> createState() => _MinisViewState();
}

class _MinisViewState extends State<MinisView> {
  final Future<Album?> album =
      AlbumService.fetchAlbumByName('site-images', null);

  static const gayleImageName = 'IMG_3051.jpg';
  static const shelbyImageNme = 'IMG_1832.jpg';
  static const momAndKidsImageName = 'IMG_2321.jpg';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentScreen: ScreensEnum.minis,
      child: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final gayleImage = snapshot.data!.images!.values!.firstWhere(
            (element) => element!.fileName == gayleImageName,
          );
          final shelbyImage = snapshot.data!.images!.values!.firstWhere(
            (element) => element!.fileName == shelbyImageNme,
          );
          final momAndKidsImage = snapshot.data!.images!.values!.firstWhere(
            (element) => element!.fileName == momAndKidsImageName,
          );
          return SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (constraints.maxWidth > 500)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: FadeInImage.memoryNetwork(
                                    fadeInDuration:
                                        const Duration(milliseconds: 1),
                                    height: 400,
                                    width: 300,
                                    placeholder: kTransparentImage,
                                    image: ImageService.getImageUrl(
                                        shelbyImage!.imageId!,
                                        ImageSizes.medium,
                                        null),
                                  ),
                                ),
                                FadeInImage.memoryNetwork(
                                  fadeInDuration:
                                      const Duration(milliseconds: 1),
                                  height: 400,
                                  width: 300,
                                  placeholder: kTransparentImage,
                                  image: ImageService.getImageUrl(
                                      gayleImage!.imageId!,
                                      ImageSizes.medium,
                                      null),
                                ),
                              ],
                            ),
                          ),
                        Column(
                          children: [
                            Padding(
                              padding: constraints.maxWidth > 400
                                  ? const EdgeInsets.all(0.0)
                                  : const EdgeInsets.only(top: 80),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  style: TextStyle(
                                    // shadows: [
                                    //   Shadow(
                                    //     color: Colors.black.withOpacity(0.35),
                                    //     blurRadius: 2,
                                    //     offset: const Offset(0, 0),
                                    //   )
                                    // ],
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'MarchRough',
                                  ),
                                  children: [
                                    TextSpan(
                                        text: "Cedar Hall Field Minis\n\n",
                                        style: TextStyle(fontSize: 35)),
                                    TextSpan(
                                        text: "NOVEMBER 3, 2024\n\n\n\n",
                                        style: TextStyle(fontSize: 35)),
                                    TextSpan(text: "15 MINUTES\n"),
                                    TextSpan(text: "UNLIMITED EDITED IMAGES\n"),
                                    TextSpan(text: "\$75\n\n\n"),
                                    TextSpan(
                                        text:
                                            "Non-refundable deposit due at booking.\n\n"),
                                    TextSpan(
                                        text:
                                            "Time slots available from 10:00 to 4:00.\n\n"),
                                    TextSpan(
                                        text:
                                            "Email below for more info and booking!\n\n"),
                                  ],
                                ),
                              ),
                            ),
                            FadeInImage.memoryNetwork(
                              fadeInDuration: const Duration(milliseconds: 1),
                              height: 300,
                              width: constraints.maxWidth > 400
                                  ? 400
                                  : constraints.maxWidth - 10,
                              placeholder: kTransparentImage,
                              image: ImageService.getImageUrl(
                                  momAndKidsImage!.imageId!,
                                  ImageSizes.medium,
                                  null),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ContactForm(
                        formWidth: constraints.maxWidth > 400
                            ? 400
                            : constraints.maxWidth - 10),
                    if (constraints.maxWidth < 500)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: FadeInImage.memoryNetwork(
                                fadeInDuration: const Duration(milliseconds: 1),
                                height: 400,
                                width: 300,
                                placeholder: kTransparentImage,
                                image: ImageService.getImageUrl(
                                    gayleImage!.imageId!,
                                    ImageSizes.medium,
                                    null),
                              ),
                            ),
                            FadeInImage.memoryNetwork(
                              fadeInDuration: const Duration(milliseconds: 1),
                              height: 400,
                              width: 300,
                              placeholder: kTransparentImage,
                              image: ImageService.getImageUrl(
                                  shelbyImage!.imageId!,
                                  ImageSizes.medium,
                                  null),
                            ),
                          ],
                        ),
                      ),
                    const AppFooter()
                  ],
                );
              },
            ),
          );
        },
        future: album,
      ),
    );
  }
}
