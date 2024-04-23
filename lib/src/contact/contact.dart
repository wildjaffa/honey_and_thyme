import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:web/web.dart' as html;

import '../../utils/constants.dart';

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  static const String route = '/contact';

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  final formKey = GlobalKey<FormState>();

  var autoValidateMode = AutovalidateMode.disabled;
  void onSubmit() {
    if (!formKey.currentState!.validate()) {
      setState(() {
        autoValidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }
    print('Form is valid');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth < 400 ? screenWidth - 80 : screenWidth / 2;
    return AppScaffold(
      currentScreen: ScreensEnum.contact,
      child: SingleChildScrollView(
        child: Form(
          autovalidateMode: autoValidateMode,
          key: formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(maxWidth: 600),
                child: Flexible(
                  child: Text(
                    'Follow me on Facebook and Instagram to see all my '
                    'upcoming events and deals.',
                    style: GoogleFonts.imFellEnglish(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const Row(
                children: [
                  Spacer(
                    flex: 2,
                  ),
                  ExternalLinkIcon(
                    linkUrl: 'https://google.com',
                    assetPath: 'images/Instagram_Glyph_Gradient.png',
                  ),
                  Spacer(flex: 1),
                  ExternalLinkIcon(
                    assetPath: '/images/Facebook_Logo_Primary.png',
                    linkUrl:
                        'https://www.facebook.com/profile.php?id=100088143396234',
                  ),
                  Spacer(
                    flex: 2,
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 80, top: 40, bottom: 10),
                    child: Text('Contact:',
                        style: GoogleFonts.imFellEnglish(
                          color: Colors.black,
                          fontSize: 18,
                        )),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 40,
                        top: 20,
                        bottom: 20,
                      ),
                      color: Colors.white,
                      width: formWidth,
                      height: 60,
                      child: Center(
                        child: TextFormField(
                          maxLength: 254,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            counterText: '',
                            errorStyle:
                                const TextStyle(height: 0.1, fontSize: 8),
                            hintText: 'Email',
                            hintStyle: GoogleFonts.imFellEnglish(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 40,
                        top: 20,
                        bottom: 20,
                      ),
                      color: Colors.white,
                      width: formWidth,
                      height: 200,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a message';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        maxLength: 1000,
                        decoration: InputDecoration(
                          counterText: '',
                          errorStyle: const TextStyle(height: 0.1, fontSize: 8),
                          hintText: 'Message',
                          hintStyle: GoogleFonts.imFellEnglish(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 50),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: formWidth + 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Constants.goldColor),
                          ),
                          onPressed: onSubmit,
                          child: Text(
                            'Send',
                            style: GoogleFonts.imFellEnglish(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
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
