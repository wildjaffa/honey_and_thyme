import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';
import '../services/contact_service.dart';
import 'booking.dart';

class ContactForm extends StatefulWidget {
  const ContactForm({
    super.key,
    required this.formWidth,
  });
  final double formWidth;
  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
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
    return SizedBox(
      width: widget.formWidth,
      child: Form(
        autovalidateMode: autoValidateMode,
        key: formKey,
        child: Column(
          children: [
            if (contactState == ContactState.failed)
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 20),
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: widget.formWidth - 20,
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
                        const EdgeInsets.only(left: 50, top: 40, bottom: 10),
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
                    padding: const EdgeInsets.only(left: 10.0, bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 10,
                        top: 20,
                        bottom: 20,
                      ),
                      color: Colors.white,
                      width: widget.formWidth - 20,
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
                            border: InputBorder.none,
                            focusColor: Colors.transparent,
                            focusedBorder: InputBorder.none,
                            hoverColor: Colors.transparent,
                            enabledBorder: InputBorder.none,
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
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 10,
                        top: 20,
                        bottom: 20,
                      ),
                      color: Colors.white,
                      width: widget.formWidth - 20,
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
                          border: InputBorder.none,
                          focusColor: Colors.transparent,
                          focusedBorder: InputBorder.none,
                          hoverColor: Colors.transparent,
                          enabledBorder: InputBorder.none,
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
            if (contactState != ContactState.sent)
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 50),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: widget.formWidth + 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            backgroundColor: WidgetStateProperty.all<Color>(
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
          ],
        ),
      ),
    );
  }
}
