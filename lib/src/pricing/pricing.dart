import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/contact/contact.dart';
import 'package:honey_and_thyme/src/models/enums/image_sizes.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/services/album_service.dart';
import 'package:honey_and_thyme/src/services/image_service.dart';
import 'package:honey_and_thyme/src/services/utils/image_utils.dart';
import 'package:honey_and_thyme/src/widgets/app_footer.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:honey_and_thyme/utils/constants.dart';
import 'package:transparent_image/transparent_image.dart';

import '../models/album.dart';

class PricingView extends StatelessWidget {
  PricingView({super.key});

  static const String route = '/pricing';

  final Future<Album?> album =
      AlbumService.fetchAlbumByName('site-images', null);

  // we're going to override the size property in the builder, but to start we
  // need to know the end width we want
  final List<PricingEntryData> pricingEntries = [
    PricingEntryData(
      title: 'The Mini - \$50',
      description: '5 minutes with unlimited edited images back. \n'
          'Up to 5 people. Message for pricing for additional people',
      imageId: 134,
      imageWidth: 400,
    ),
    PricingEntryData(
      title: 'The Half - \$75',
      description: '30 minutes with unlimited edited images back. '
          'Up to 5 people. Message for pricing for additional people',
      imageId: 136,
      imageWidth: 200,
    ),
    PricingEntryData(
      title: 'The Full - \$100',
      description: '60 minutes with unlimited edited images back. '
          'Up to 5 people. '
          'Message for pricing for additional people.',
      imageId: 135,
      imageWidth: 400,
    ),
    PricingEntryData(
      title: 'The Double - \$200',
      description: '120 minutes with unlimited edited images back. '
          'Up to 5 people. Message for pricing for additional people.',
      imageId: 137,
      imageWidth: 200,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var multiplier = 0.5;
    if (screenWidth > 600) {
      screenWidth = 600;
      multiplier = 1.0;
    }
    return AppScaffold(
      currentScreen: ScreensEnum.pricing,
      child: FutureBuilder(
        future: album,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading pricing page'),
            );
          }

          return Container(
            padding: const EdgeInsets.only(top: 16),
            width: 600,
            child: ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              shrinkWrap: true,
              itemCount: pricingEntries.length + 2,
              itemBuilder: (context, index) {
                if (index == pricingEntries.length + 1) {
                  return const AppFooter();
                }
                if (index == pricingEntries.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32, bottom: 16),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.imFellEnglish(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(text: "Don't see what you need? "),
                            TextSpan(
                              mouseCursor: SystemMouseCursors.click,
                              text: "CONTACT ME",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      ContactView.route,
                                      (route) => route.isFirst);
                                },
                              style: const TextStyle(
                                color: Constants.goldColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(
                                text:
                                    ". I'd love to create a custom package for you!"),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final pricingEntry = pricingEntries[index];
                final image = snapshot.data!.images!.values!.firstWhere(
                  (element) => element!.imageId == pricingEntry.imageId,
                );
                return Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: screenWidth,
                    child: PricingEntry(
                      backgroundColor: index % 2 == 0
                          ? Colors.transparent
                          : Constants.sageColor,
                      width: screenWidth,
                      pricingEntryData: pricingEntry,
                      imageSize: ImageUtils.calculateImageSize(
                        aspectRatio: image!.metaData!.aspectRatio!,
                        imageWidth: pricingEntry.imageWidth * multiplier,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class PricingEntry extends StatelessWidget {
  final double width;
  final Size imageSize;
  final Color backgroundColor;
  const PricingEntry({
    super.key,
    required this.pricingEntryData,
    required this.width,
    required this.imageSize,
    required this.backgroundColor,
  });

  final PricingEntryData pricingEntryData;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: imageSize.height,
        maxWidth: width,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        // border: Border.all(color: Constants.sageColor),
        // borderRadius: BorderRadius.circular(8),
        // boxShadow: const [
        //   BoxShadow(
        //     color: Constants.sageColor,
        //     spreadRadius: 1,
        //     blurRadius: 2,
        //     offset: Offset(3, 3),
        //   ),
        // ]),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8),
            child: FadeInImage.memoryNetwork(
              height: imageSize.height,
              width: imageSize.width,
              placeholder: kTransparentImage,
              image: ImageService.getImageUrl(
                  pricingEntryData.imageId, ImageSizes.large, null),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pricingEntryData.title,
                style: GoogleFonts.imFellEnglishSc(
                  fontSize: 18,
                  color: Colors.black,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(
                width: width - (imageSize.width + 50),
                child: Text(
                  pricingEntryData.description,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.imFellEnglish(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PricingEntryData {
  String title;
  String description;
  int imageId;
  double imageWidth;

  PricingEntryData({
    required this.title,
    required this.description,
    required this.imageId,
    required this.imageWidth,
  });
}
