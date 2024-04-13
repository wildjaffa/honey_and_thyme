import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:transparent_image/transparent_image.dart';

class PricingView extends StatelessWidget {
  const PricingView({super.key});

  static const String route = '/pricing';

  final List<PricingEntryData> pricingEntries = const [
    PricingEntryData(
      imageHeight: 100,
      imageWidth: 150,
      title: 'The Mini - \$50',
      description: '5 minutes with unlimited edited images back. \n'
          'Up to 5 people. Message for pricing for additional people',
      imageUrl: 'http://jensennas.local:8568/assets/HomePage/IMG_1636.jpg',
    ),
    PricingEntryData(
      imageHeight: 150,
      imageWidth: 100,
      title: 'The Half - \$75',
      description: '30 minutes with unlimited edited images back. '
          'Up to 5 people. Message for pricing for additional people',
      imageUrl:
          'http://jensennas.local:8568/assets/HomePage/PXL_20221218_174920383.PORTRAIT.jpg',
    ),
    PricingEntryData(
      imageHeight: 100,
      imageWidth: 150,
      title: 'The Full - \$100',
      description: '60 minutes with unlimited edited images back. '
          'Up to 5 people. '
          'Message for pricing for additional people.',
      imageUrl:
          'http://jensennas.local:8568/assets/HomePage/PXL_20231109_195510638.PORTRAIT.ORIGINAL.jpg',
    ),
    PricingEntryData(
      imageHeight: 150,
      imageWidth: 100,
      title: 'The Double - \$200',
      description: '120 minutes with unlimited edited images back. '
          'Up to 5 people. Message for pricing for additional people.',
      imageUrl:
          'http://jensennas.local:8568/assets/HomePage/PXL_20231109_195510638.PORTRAIT.ORIGINAL.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      screenWidth = 600;
    }
    return AppScaffold(
      currentScreen: ScreensEnum.pricing,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: pricingEntries.length,
        itemBuilder: (context, index) {
          return UnconstrainedBox(
            child: SizedBox(
              width: screenWidth,
              child: PricingEntry(
                width: screenWidth,
                pricingEntryData: pricingEntries[index],
              ),
            ),
          );
        },
      ),
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
    return Container(
      constraints: BoxConstraints(
        minHeight: pricingEntryData.imageHeight,
        maxWidth: width,
      ),
      padding: const EdgeInsets.only(top: 80),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FadeInImage.memoryNetwork(
              height: pricingEntryData.imageHeight,
              width: pricingEntryData.imageWidth,
              placeholder: kTransparentImage,
              image: pricingEntryData.imageUrl,
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
                  maxWidth: width - (pricingEntryData.imageWidth + 20),
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
  final String title;
  final String description;
  final String imageUrl;
  final double imageHeight;
  final double imageWidth;

  const PricingEntryData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.imageHeight,
    required this.imageWidth,
  });
}
