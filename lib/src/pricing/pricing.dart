import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/models/enums/image_sizes.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/services/album_service.dart';
import 'package:honey_and_thyme/src/services/image_service.dart';
import 'package:honey_and_thyme/src/services/utils/image_utils.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
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

            return ListView.builder(
              shrinkWrap: true,
              itemCount: pricingEntries.length,
              itemBuilder: (context, index) {
                final pricingEntry = pricingEntries[index];
                final image = snapshot.data!.images!.values!.firstWhere(
                  (element) => element!.imageId == pricingEntry.imageId,
                );
                return SizedBox(
                  width: screenWidth,
                  child: PricingEntry(
                    width: screenWidth,
                    pricingEntryData: pricingEntry,
                    imageSize: ImageUtils.calculateImageSize(
                        aspectRatio: image!.metaData!.aspectRatio!,
                        imageWidth: pricingEntry.imageWidth * multiplier),
                  ),
                );
              },
            );
          }),
    );
  }
}

class PricingEntry extends StatelessWidget {
  final double width;
  final Size imageSize;
  const PricingEntry(
      {super.key,
      required this.pricingEntryData,
      required this.width,
      required this.imageSize});

  final PricingEntryData pricingEntryData;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: imageSize.height,
        maxWidth: width,
      ),
      padding: const EdgeInsets.only(top: 80),
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
                width: width - (imageSize.width + 30),
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
