import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:honey_and_thyme/src/js_interop/paypal_interop.dart';
import 'package:honey_and_thyme/src/services/api_service.dart';
import 'firebase_options.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app);

  PayPalInterop.setBaseUrl(ApiService.getUri(ApiService.url).toString());
  PayPalInterop.setCaptureAmount(100.0);
  // ignore: undefined_prefixed_name
  // ui.platformViewRegistry.registerViewFactory(
  //   'paypal-button',
  //   (int viewId) => IFrameElement()..src = "./paypal.html",
  // );
  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));
}
