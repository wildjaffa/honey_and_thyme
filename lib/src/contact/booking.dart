import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/services/contact_service.dart';
import 'package:honey_and_thyme/src/widgets/app_footer.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:honey_and_thyme/src/widgets/loading_button.dart';

import '../../utils/constants.dart';
import '../models/booking_request.dart';
import '../widgets/honey_dropdown_field.dart';
import '../widgets/honey_input_field.dart';

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
                Padding(
                  padding: const EdgeInsets.only(left: 50.0, top: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Please enter the details of your booking request below.',
                          style: GoogleFonts.imFellEnglish(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        HoneyInputField(
                          initialValue: '',
                          label: 'Name',
                          onChanged: (value) => setState(() {
                            bookingRequest.name = value;
                          }),
                          enabled: contactState != ContactState.sending,
                          width: formWidth,
                        ),
                        HoneyInputField(
                          initialValue: '',
                          label: 'Email',
                          onChanged: (value) => setState(() {
                            bookingRequest.email = value;
                          }),
                          enabled: contactState != ContactState.sending,
                          width: formWidth,
                        ),
                        HoneyInputField(
                          initialValue: '',
                          label: 'Number of Guests',
                          onChanged: (value) => setState(() {
                            bookingRequest.numberOfPeople = int.tryParse(value);
                          }),
                          keyboardType: TextInputType.number,
                          enabled: contactState != ContactState.sending,
                          width: formWidth,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                        HoneyDropdownField(
                          value: bookingRequest.sessionLength,
                          label: 'Session Length',
                          onChanged: (value) => setState(() {
                            bookingRequest.sessionLength = value;
                          }),
                          enabled: contactState != ContactState.sending,
                          width: formWidth,
                          items: const [
                            'Mini',
                            'Half',
                            'Full',
                            'Double',
                            'Other'
                          ],
                        ),
                        HoneyInputField(
                          initialValue: '',
                          label: 'Occasion',
                          onChanged: (value) => setState(() {
                            bookingRequest.occasion = value;
                          }),
                          enabled: contactState != ContactState.sending,
                          width: formWidth,
                          hintText:
                              'e.g. Birthday, Anniversary, couples/family etc.',
                        ),
                        HoneyInputField(
                          initialValue: '',
                          label: 'Location Preferences',
                          onChanged: (value) => setState(() {
                            bookingRequest.location = value;
                          }),
                          enabled: contactState != ContactState.sending,
                          width: formWidth,
                          hintText:
                              'e.g. Indoor, Outdoor, Specific Location, Aesthetic etc',
                        ),
                        HoneyInputField(
                          initialValue: '',
                          label: 'Other Info Or Questions',
                          onChanged: (value) => setState(() {
                            bookingRequest.questions = value;
                          }),
                          enabled: contactState != ContactState.sending,
                          width: formWidth,
                          keyboardType: TextInputType.multiline,
                          maxLines: 8,
                          minLines: 5,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: formWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              LoadingButton(
                                text: 'Send',
                                onPressed: onSubmit,
                                isLoading: contactState == ContactState.sending,
                              ),
                            ],
                          ),
                        ),
                      ],
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
