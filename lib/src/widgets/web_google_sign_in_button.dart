import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart';
import '../services/calendar_service.dart';

class WebGoogleSignInButton extends StatefulWidget {
  final Function(String authCode)? onAuthCodeReceived;
  final Function(String error)? onError;

  const WebGoogleSignInButton({
    super.key,
    this.onAuthCodeReceived,
    this.onError,
  });

  @override
  State<WebGoogleSignInButton> createState() => _WebGoogleSignInButtonState();
}

class _WebGoogleSignInButtonState extends State<WebGoogleSignInButton> {
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      // Initialize Google Sign-In first
      await CalendarService.initialize();

      // Set up authentication listener after initialization
      _setupAuthenticationListener();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing Google Sign-In: $e');
      widget.onError?.call('Failed to initialize Google Sign-In: $e');
    }
  }

  void _setupAuthenticationListener() {
    // Listen to authentication events
    GoogleSignIn.instance.authenticationEvents.listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        _handleSuccessfulSignIn(event.user);
      } else if (event is GoogleSignInAuthenticationEventSignOut) {
        // Handle sign out if needed
        print('User signed out');
      }
    });
  }

  Future<void> _handleSuccessfulSignIn(GoogleSignInAccount user) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the server auth code for this user
      final String? authCode = await CalendarService.getServerAuthCode(user);

      if (authCode != null) {
        widget.onAuthCodeReceived?.call(authCode);
      } else {
        widget.onError?.call('Failed to get server auth code');
      }
    } catch (e) {
      widget.onError?.call('Error during sign-in: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox(
        width: 200,
        height: 40,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isLoading) {
      return const SizedBox(
        width: 200,
        height: 40,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Use the web-specific renderButton method from the web-only library
    return SizedBox(
      width: 200,
      height: 40,
      child: renderButton(),
    );
  }
}
