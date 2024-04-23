import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:honey_and_thyme/src/admin/album/edit_album.dart';
import 'package:honey_and_thyme/src/albums/album.dart';
import 'package:honey_and_thyme/src/contact/contact.dart';
import 'package:honey_and_thyme/src/pricing/pricing.dart';

import '../utils/constants.dart';
import 'admin/admin.dart';
import 'home/home.dart';

import 'settings/settings_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // debugShowCheckedModeBanner: false,
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Constants.goldColor,
              selectionColor: Constants.goldColor.withOpacity(0.3),
              selectionHandleColor: Constants.goldColor,
            ),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: Constants.goldColor,
              secondary: Constants.goldColor,
              // error:
            ),
            inputDecorationTheme:
                const InputDecorationTheme(border: InputBorder.none),
          ),
          // darkTheme: ThemeData.dark(

          // ),
          themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            final routeParts = routeSettings.name!.split('?');
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                if (routeParts[0].startsWith('/albums')) {
                  final albumName = routeParts[0].replaceAll('/albums/', '');
                  return AlbumView(
                    albumName: albumName,
                  );
                }

                switch (routeParts[0]) {
                  case PricingView.route:
                    return const PricingView();
                  case ContactView.route:
                    return const ContactView();
                  case AdminView.route:
                    return const AdminView();
                  case EditAlbum.route:
                    return EditAlbum(
                        albumId: int.parse(routeParts[1].split('=')[1]));
                  default:
                    return const Home();
                }
              },
            );
          },
        );
      },
    );
  }
}
