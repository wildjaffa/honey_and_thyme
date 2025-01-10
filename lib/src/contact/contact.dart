import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/contact/contact_form.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/widgets/app_footer.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:web/web.dart' as html;

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  static const String route = '/contact';

  @override
  State<ContactView> createState() => _ContactViewState();
}

enum ContactState {
  notSent,
  sending,
  sent,
  failed,
}

class _ContactViewState extends State<ContactView> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final formWidth = screenWidth < 450 ? screenWidth - 80 : screenWidth / 3;
    return AppScaffold(
      currentScreen: ScreensEnum.contact,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 600),
              child: Text(
                'Follow me on Facebook and Instagram to see all my '
                'upcoming events and deals.',
                style: GoogleFonts.imFellEnglish(
                  color: Colors.black,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Row(
              children: [
                Spacer(
                  flex: 2,
                ),
                ExternalLinkIcon(
                  linkUrl:
                      'https://www.instagram.com/honeyandthymephotography?igsh=ZDd4cTk2M3cwYzU5',
                  assetPath: 'assets/images/Instagram_Glyph_Gradient.png',
                ),
                Spacer(flex: 1),
                ExternalLinkIcon(
                  assetPath: 'assets/images/Facebook_Logo_Primary.png',
                  linkUrl:
                      'https://www.facebook.com/profile.php?id=100088143396234',
                ),
                Spacer(
                  flex: 2,
                ),
              ],
            ),
            ContactForm(formWidth: formWidth),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

class ExternalLinkIcon extends StatelessWidget {
  final String linkUrl;
  final String assetPath;

  const ExternalLinkIcon({
    super.key,
    required this.linkUrl,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          html.window.open(linkUrl, 'new tab');
        },
        child: SizedBox(
          height: 50,
          width: 50,
          child: Image(
            image: AssetImage(assetPath),
          ),
        ),
      ),
    );
  }
}
