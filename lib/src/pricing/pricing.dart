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
        imageSize: const Size(200, 0)),
    PricingEntryData(
        title: 'The Half - \$75',
        description: '30 minutes with unlimited edited images back. '
            'Up to 5 people. Message for pricing for additional people',
        imageId: 136,
        imageSize: const Size(100, 0)),
    PricingEntryData(
        title: 'The Full - \$100',
        description: '60 minutes with unlimited edited images back. '
            'Up to 5 people. '
            'Message for pricing for additional people.',
        imageId: 135,
        imageSize: const Size(200, 0)),
    PricingEntryData(
        title: 'The Double - \$200',
        description: '120 minutes with unlimited edited images back. '
            'Up to 5 people. Message for pricing for additional people.',
        imageId: 137,
        imageSize: const Size(100, 0)),
  ];

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      screenWidth = 600;
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
            var multiplier = 1.0;
            if (screenWidth > 600) {
              multiplier = 2.0;
            }
            for (var pricingEntry in pricingEntries) {
              final image = snapshot.data!.images!.values!.firstWhere(
                (element) => element!.imageId == pricingEntry.imageId,
              );
              pricingEntry.imageSize = ImageUtils.calculateImageSize(
                  aspectRatio: image!.metaData!.aspectRatio!,
                  imageWidth: pricingEntry.imageSize!.width * multiplier);
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: pricingEntries.length,
              itemBuilder: (context, index) {
                final pricingEntry = pricingEntries[index];
                return UnconstrainedBox(
                  child: SizedBox(
                    width: screenWidth,
                    child: PricingEntry(
                      width: screenWidth,
                      pricingEntryData: pricingEntry,
                    ),
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
  const PricingEntry({
    super.key,
    required this.pricingEntryData,
    required this.width,
  });

  final PricingEntryData pricingEntryData;

  @override
  Widget build(BuildContext context) {
    print(pricingEntryData.imageSize!.height);
    return Container(
      constraints: BoxConstraints(
        minHeight: pricingEntryData.imageSize!.height,
        maxWidth: width,
      ),
      padding: const EdgeInsets.only(top: 80),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8),
            child: FadeInImage.memoryNetwork(
              height: pricingEntryData.imageSize!.height,
              width: pricingEntryData.imageSize!.width,
              placeholder: kTransparentImage,
              image: ImageService.getImageUrl(
                  pricingEntryData.imageId, ImageSizes.medium, null),
            ),
          ),
          Column(
            children: [
              Text(
                pricingEntryData.title,
                style: GoogleFonts.imFellEnglishSc(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width - (pricingEntryData.imageSize!.width + 30),
                ),
                child: Flexible(
                  child: Text(
                    pricingEntryData.description,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.imFellEnglish(
                      fontSize: 12,
                      color: Colors.black,
                    ),
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
  Size? imageSize;

  PricingEntryData({
    required this.title,
    required this.description,
    required this.imageId,
    this.imageSize,
  });
}
