import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/admin/login_form.dart';

class Authenticate extends StatefulWidget {
  final Widget child;
  const Authenticate({
    super.key,
    required this.child,
  });

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  late bool isAuthenticated;

  @override
  void initState() {
    isAuthenticated = FirebaseAuth.instance.currentUser != null;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isAuthenticated
        ? widget.child
        : Center(
            child: LoginForm(
              onSignIn: () {
                setState(() {
                  isAuthenticated = true;
                });
              },
            ),
          );
  }
}
