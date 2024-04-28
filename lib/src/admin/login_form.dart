import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/services/user_service.dart';

class LoginForm extends StatelessWidget {
  final void Function() onSignIn;
  const LoginForm({super.key, required this.onSignIn});

  signInWithGoogle() async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithPopup(googleProvider);
    await UserService.userSignedIn();
    onSignIn();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: ElevatedButton(
        onPressed: signInWithGoogle,
        child: const Text('Sign in with Google'),
      ),
    );
  }
}
