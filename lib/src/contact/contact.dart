import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/services/contact_service.dart';
import 'package:honey_and_thyme/src/widgets/app_footer.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:web/web.dart' as html;

import '../../utils/constants.dart';

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
  final formKey = GlobalKey<FormState>();

  ContactState contactState = ContactState.notSent;
  String contactMessage = '';
  String contactEmail = '';

  var autoValidateMode = AutovalidateMode.disabled;
  Future<void> onSubmit() async {
    if (!formKey.currentState!.validate()) {
      setState(() {
        autoValidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }
    final stopWatch = Stopwatch()..start();
    setState(() {
      contactState = ContactState.sending;
    });
    final result =
        await ContactService.sendContactMessage(contactEmail, contactMessage);
    if (stopWatch.elapsedMilliseconds < 500) {
      await Future.delayed(
          Duration(milliseconds: 500 - stopWatch.elapsedMilliseconds));
    }
    setState(() {
      contactState = result ? ContactState.sent : ContactState.failed;
    });
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Constants.pinkColor,
          title: const Text('Message Sent'),
          content: const Text(
              'Your message has been sent. We will get back to you as soon as possible. Thank you!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final formWidth = screenWidth < 450 ? screenWidth - 80 : screenWidth / 2;
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
              if (contactState == ContactState.failed)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 50),
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: formWidth,
                      child: Text(
                        'Sorry, there was an issue trying to submit your message. Please try again later.',
                        style: GoogleFonts.imFellEnglish(
                          fontSize: 18,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              if (contactState != ContactState.sent)
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
              if (contactState != ContactState.sent)
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
                            enabled: contactState != ContactState.sending,
                            onChanged: (value) {
                              contactEmail = value;
                            },
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
              if (contactState != ContactState.sent)
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
                          enabled: contactState != ContactState.sending,
                          onChanged: (value) {
                            contactMessage = value;
                          },
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
                            errorStyle:
                                const TextStyle(height: 0.1, fontSize: 8),
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
              if (contactState != ContactState.sent)
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
                            onPressed: contactState != ContactState.sending
                                ? onSubmit
                                : null,
                            child: contactState == ContactState.sending
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
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
                ),
              const AppFooter(),
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
