import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:honey_and_thyme/src/admin/album/album_list.dart';
import 'package:honey_and_thyme/src/admin/album/edit_album.dart';
import 'package:honey_and_thyme/src/admin/photo_shoot/photo_shoot_list.dart';
import 'package:honey_and_thyme/src/admin/product/product_list.dart';
import 'package:honey_and_thyme/src/albums/album.dart';
import 'package:honey_and_thyme/src/albums/gallery.dart';
import 'package:honey_and_thyme/src/contact/booking.dart';
import 'package:honey_and_thyme/src/contact/contact.dart';
import 'package:honey_and_thyme/src/contact/upcoming_appointments.dart';
import 'package:honey_and_thyme/src/payment/invoice.dart';
import 'package:honey_and_thyme/src/minis/minis.dart';
import 'package:honey_and_thyme/src/pricing/pricing.dart';

import '../utils/constants.dart';
import 'admin/admin.dart';
import 'admin/email_records/email_records_list.dart';
import 'home/home.dart';

import 'settings/settings_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  static const errorStyle = TextStyle(height: 0.1, fontSize: 8);
  static final hintStyle = GoogleFonts.imFellEnglish(
    color: Constants.sageColor,
    fontSize: 16,
  );

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
          title: 'Honey and Thyme',
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
            textTheme: GoogleFonts.imFellEnglishTextTheme(
              Theme.of(context).textTheme,
            ),
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
            inputDecorationTheme: InputDecorationTheme(
              errorStyle: errorStyle,
              hintStyle: hintStyle,
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Constants.sageColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Constants.goldColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Constants.pinkColor),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Constants.pinkColor, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 12.0,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                textStyle: GoogleFonts.imFellEnglish(
                  fontSize: 18,
                  color: Colors.black,
                ),
                backgroundColor: Constants.goldColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
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
                    return PricingView();
                  case ContactView.route:
                    return const ContactView();
                  case AdminView.route:
                    return const AdminView();
                  case PublicGallery.route:
                    return const PublicGallery();
                  case BookingView.route:
                    return const BookingView();
                  case EditAlbum.route:
                    return EditAlbum(albumId: routeParts[1].split('=')[1]);
                  case MinisView.route:
                    return const MinisView();
                  case AlbumList.route:
                    return const AlbumList();
                  case ProductList.route:
                    return const ProductList();
                  case PhotoShootList.route:
                    return const PhotoShootList();
                  case Invoice.route:
                    return Invoice(
                        reservationCode: routeParts[1].split('=')[1]);
                  case EmailRecordsList.route:
                    return const EmailRecordsList();
                  case UpcomingAppointments.route:
                    return const UpcomingAppointments();
                  default:
                    final homePageLoaded = settingsController.homePageLoaded;
                    settingsController.homePageLoaded = true;
                    return Home(slowLoadImages: homePageLoaded);
                }
              },
            );
          },
        );
      },
    );
  }
}
