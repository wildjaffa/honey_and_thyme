import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/widgets/honey_input_field.dart';
import 'package:honey_and_thyme/src/widgets/loading_button.dart';

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
            if (contactState != ContactState.sent) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 10),
                    child: Text('Contact:',
                        style: GoogleFonts.imFellEnglish(
                          color: Colors.black,
                          fontSize: 18,
                        )),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
              HoneyInputField(
                initialValue: contactEmail,
                label: 'Email',
                onChanged: (value) {
                  contactEmail = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              HoneyInputField(
                initialValue: contactMessage,
                label: 'Message',
                onChanged: (value) {
                  contactMessage = value;
                },
                maxLines: 8,
                minLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  LoadingButton(
                    text: 'Send',
                    onPressed: onSubmit,
                    isLoading: contactState == ContactState.sending,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
