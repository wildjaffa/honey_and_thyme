import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/admin/album/album_list.dart';
import 'package:honey_and_thyme/src/admin/authenticate.dart';
import 'package:honey_and_thyme/src/admin/calendar_settings.dart';
import 'package:honey_and_thyme/src/admin/email_records/email_records_list.dart';
import 'package:honey_and_thyme/src/admin/photo_shoot/photo_shoot_list.dart';
import 'package:honey_and_thyme/src/admin/product/product_list.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';

import '../contact/upcoming_appointments.dart';

class AdminView extends StatefulWidget {
  const AdminView({
    super.key,
  });

  static const String route = '/admin';

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentScreen: ScreensEnum.admin,
      child: Authenticate(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              AdminNavigationButton(
                route: AlbumList.route,
                text: 'Albums',
              ),
              AdminNavigationButton(
                route: PhotoShootList.route,
                text: 'Photo Shoots',
              ),
              AdminNavigationButton(
                route: ProductList.route,
                text: 'Products',
              ),
              AdminNavigationButton(
                route: EmailRecordsList.route,
                text: 'Email Records',
              ),
              AdminNavigationButton(
                route: UpcomingAppointments.route,
                text: 'Upcoming Appointments',
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 300,
                child: CalendarSettingsSelection(),
              ),
              const SizedBox(height: 32),
              const Text('Site Version: 1.1.1'),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminNavigationButton extends StatelessWidget {
  final String route;
  final String text;
  const AdminNavigationButton({
    super.key,
    required this.route,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        child: Text(text),
      ),
    );
  }
}
