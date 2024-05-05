import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/services/contact_service.dart';
import 'package:honey_and_thyme/src/widgets/app_footer.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';

import '../../utils/constants.dart';
import '../models/booking_request.dart';

class BookingView extends StatefulWidget {
  const BookingView({super.key});

  static const String route = '/booking';

  @override
  State<BookingView> createState() => _BookingViewState();
}

enum ContactState {
  notSent,
  sending,
  sent,
  failed,
}

class _BookingViewState extends State<BookingView> {
  final formKey = GlobalKey<FormState>();

  ContactState contactState = ContactState.notSent;
  BookingRequest bookingRequest = BookingRequest();

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
    final result = await ContactService.sendBookingRequest(bookingRequest);
    if (stopWatch.elapsedMilliseconds < 500) {
      await Future.delayed(
          Duration(milliseconds: 500 - stopWatch.elapsedMilliseconds));
    }
    setState(() {
      contactState = result ? ContactState.sent : ContactState.failed;
    });
    if (!result) {
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Constants.pinkColor,
          title: const Text('Booking Request Sent'),
          content: const Text(
              'Your booking request has been sent. We will get back to you as soon as possible. Thank you!'),
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
              if (contactState == ContactState.sent)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Your booking request has been sent. We will get back to you as soon as possible. Thank you!',
                      style: GoogleFonts.imFellEnglish(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0, top: 20),
                      child: Text(
                        'Please enter the details of your booking request below.',
                        style: GoogleFonts.imFellEnglish(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    FormField(
                      label: 'Name',
                      hintText: 'Enter Your Name',
                      onChanged: (value) => setState(() {
                        bookingRequest.name = value;
                      }),
                      value: bookingRequest.name,
                      formWidth: formWidth,
                      enabled: contactState != ContactState.sending,
                    ),
                    FormField(
                      label: 'Email',
                      hintText: 'Enter Your Email',
                      onChanged: (value) => setState(() {
                        bookingRequest.email = value;
                      }),
                      value: bookingRequest.email,
                      formWidth: formWidth,
                      enabled: contactState != ContactState.sending,
                    ),
                    FormField(
                      label: 'Number of Guests',
                      hintText: 'Enter Number of Guests',
                      onChanged: (value) => setState(() {
                        bookingRequest.numberOfPeople = int.tryParse(value!);
                      }),
                      value: bookingRequest.numberOfPeople?.toString(),
                      formWidth: formWidth,
                      keyboardType: TextInputType.number,
                      enabled: contactState != ContactState.sending,
                    ),
                    FormField(
                      label: 'Session Length',
                      hintText: 'Select Session Length',
                      onChanged: (value) => setState(() {
                        bookingRequest.sessionLength = value;
                      }),
                      value: bookingRequest.sessionLength,
                      formWidth: formWidth,
                      enabled: contactState != ContactState.sending,
                      options: const [
                        'Mini',
                        'Half',
                        'Full',
                        'Double',
                        'Other'
                      ],
                    ),
                    FormField(
                      label: 'Occasion',
                      hintText: 'Enter Occasion',
                      onChanged: (value) => setState(() {
                        bookingRequest.occasion = value;
                      }),
                      value: bookingRequest.occasion,
                      formWidth: formWidth,
                      enabled: contactState != ContactState.sending,
                    ),
                    FormField(
                      label: 'Location Preferences',
                      hintText: 'Enter Location Preferences',
                      onChanged: (value) => setState(() {
                        bookingRequest.location = value;
                      }),
                      value: bookingRequest.occasion,
                      formWidth: formWidth,
                      enabled: contactState != ContactState.sending,
                    ),
                    FormField(
                      label: 'Other Info Or Questions',
                      hintText: 'Enter Other Info Or Questions (Optional)',
                      onChanged: (value) => setState(() {
                        bookingRequest.questions = value;
                      }),
                      keyboardType: TextInputType.multiline,
                      value: bookingRequest.questions,
                      formWidth: formWidth,
                      enabled: contactState != ContactState.sending,
                      required: false,
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
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
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
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class FormField extends StatelessWidget {
  final String label;
  final String hintText;
  final String? value;
  final double formWidth;
  final bool enabled;
  final TextInputType keyboardType;
  final List<String>? options;
  final bool required;
  final void Function(String?) onChanged;
  const FormField({
    super.key,
    required this.label,
    required this.hintText,
    this.value,
    required this.onChanged,
    required this.formWidth,
    required this.enabled,
    this.keyboardType = TextInputType.text,
    this.required = true,
    this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 40.0, top: 20),
          child: Text(
            label,
            style: GoogleFonts.imFellEnglish(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Container(
            padding: const EdgeInsets.only(
              left: 40,
              top: 8,
              // bottom: 20,
            ),
            color: Colors.white,
            width: formWidth,
            height: keyboardType == TextInputType.multiline ? 200 : 60,
            child: options == null
                ? TextFormField(
                    initialValue: value,
                    enabled: enabled,
                    onChanged: onChanged,
                    validator: (value) {
                      if (required && (value == null || value.isEmpty)) {
                        return 'Please enter a value';
                      }
                      return null;
                    },
                    keyboardType: keyboardType,
                    inputFormatters: keyboardType == TextInputType.number
                        ? <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ]
                        : null,
                    maxLines: null,
                    maxLength:
                        keyboardType == TextInputType.multiline ? 1000 : 254,
                    decoration: InputDecoration(
                      counterText: '',
                      errorStyle: const TextStyle(height: 0.1, fontSize: 8),
                      hintText: hintText,
                      hintStyle: GoogleFonts.imFellEnglish(
                        color: Constants.sageColor,
                        fontSize: 18,
                      ),
                    ),
                  )
                : DropdownButtonFormField<String>(
                    value: value,
                    hint: Text(
                      hintText,
                      style: GoogleFonts.imFellEnglish(
                        color: Constants.sageColor,
                        fontSize: 18,
                      ),
                    ),
                    dropdownColor: Colors.white,
                    onChanged: enabled ? onChanged : null,
                    items:
                        options!.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }
}
