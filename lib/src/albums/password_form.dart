import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordForm extends StatelessWidget {
  final void Function() onSubmitted;
  final int passwordAttempts;
  final Future<void> fontLoader;
  final void Function(String) onPasswordChanged;
  final double formWidth;

  const PasswordForm({
    super.key,
    required this.onSubmitted,
    required this.passwordAttempts,
    required this.fontLoader,
    required this.onPasswordChanged,
    required this.formWidth,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fontLoader,
      builder: (context, snapshot) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        child: snapshot.connectionState != ConnectionState.done
            ? const SizedBox(key: ValueKey('loading'))
            : Center(
                key: const ValueKey('password'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 38,
                          top: 15,
                          bottom: 20,
                        ),
                        color: Colors.white,
                        width: formWidth,
                        height: 60,
                        child: Center(
                          child: TextFormField(
                            style: GoogleFonts.imFellEnglish(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            onChanged: onPasswordChanged,
                            maxLength: 254,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the password';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) => onSubmitted(),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusColor: Colors.transparent,
                              focusedBorder: InputBorder.none,
                              hoverColor: Colors.transparent,
                              enabledBorder: InputBorder.none,
                              counterText: '',
                              errorStyle:
                                  const TextStyle(height: 0.1, fontSize: 8),
                              hintText: 'Please enter the password',
                              hintStyle: GoogleFonts.imFellEnglish(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onSubmitted,
                      child: const Text('Unlock'),
                    ),
                    if (passwordAttempts > 3)
                      SizedBox(
                        width: 300,
                        child: Text(
                          'If you are sure you are inputting the password correctly, '
                          'it is possible that the album has been locked for your protection. '
                          'Please contact us for more information.',
                          style: GoogleFonts.imFellEnglish(
                            color: Colors.red,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
