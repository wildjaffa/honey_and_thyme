import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/contact/new_appointments_form.dart';
import 'package:honey_and_thyme/src/models/schedule_appointment_request.dart';
import 'package:honey_and_thyme/src/models/enums/photo_shoot_status.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/services/api_service.dart';
import 'package:honey_and_thyme/src/services/utils/date_utils.dart';
import 'package:honey_and_thyme/src/widgets/app_footer.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:honey_and_thyme/src/widgets/stack_modal.dart';
import 'package:intl/intl.dart';
import 'package:signalr_core/signalr_core.dart' as signal_r;

import '../../utils/constants.dart';
import '../models/photo_shoot.dart';
import '../services/photo_shoot_service.dart';
import 'schedule_appointment_form.dart';
import 'booking.dart';

class UpcomingAppointments extends StatefulWidget {
  const UpcomingAppointments({super.key});

  static const String route = '/available-appointments';

  @override
  State<UpcomingAppointments> createState() => _UpcomingAppointmentsState();
}

class _UpcomingAppointmentsState extends State<UpcomingAppointments> {
  late Future photoShootFetch;
  Map<DateTime, List<PhotoShoot>> photoShootsByDate = {};
  DateTime? firstDate;
  late bool isAuthenticated;
  bool addingAppointmentSlots = false;
  ScheduleAppointmentRequest scheduleAppointmentRequest =
      ScheduleAppointmentRequest();
  late signal_r.HubConnection hubConnection;

  void fetchPhotoShoots() {
    photoShootFetch = PhotoShootService.fetchUpcomingAppointments(
            DateTime.now().toUtc(),
            DateTime.now().add(const Duration(days: 30)).toUtc())
        .then((values) {
      for (final photoShoot in values) {
        if (photoShoot.dateTimeUtc == null) {
          continue;
        }

        final localDate = photoShoot.dateTimeUtc!.toLocal();
        final dateKey = photoShootsByDate.keys.firstWhere(
          (x) => x.isSameDay(localDate),
          orElse: () => localDate,
        );
        if (photoShootsByDate[dateKey] == null) {
          photoShootsByDate[dateKey] = [];
        }
        photoShootsByDate[dateKey]!.add(photoShoot);
        if (firstDate == null || dateKey.isBefore(firstDate!)) {
          firstDate = dateKey;
        }
      }
      return values;
    });
  }

  void savedPhotoShoots() {
    fetchPhotoShoots();
    setState(() {
      addingAppointmentSlots = false;
    });
  }

  bool moreDatesAvailable(int columnCount) {
    final currentIndexOfFirstDate =
        photoShootsByDate.keys.toList().indexOf(firstDate!);
    bool available =
        currentIndexOfFirstDate + columnCount < photoShootsByDate.keys.length;
    return available;
  }

  PhotoShoot? getPhotoShootById(String? id) {
    if (id == null) {
      return null;
    }
    for (final photoShootList in photoShootsByDate.values) {
      for (final photoShoot in photoShootList) {
        if (photoShoot.photoShootId == id) {
          return photoShoot;
        }
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    isAuthenticated = FirebaseAuth.instance.currentUser != null;
    fetchPhotoShoots();
    _initializeSignalRConnection();
  }

  Future<void> _initializeSignalRConnection() async {
    try {
      hubConnection = ApiService.initiateSignalRHubConnection('bookingHub');
      hubConnection.on('PhotoShootScheduled', (arguments) {
        final photoShootId = arguments?[0] as String;
        final photoShoot = getPhotoShootById(photoShootId);
        if (photoShoot == null) {
          return;
        }
        setState(() {
          photoShoot.status = PhotoShootStatus.booked;
        });
      });

      hubConnection.on('PhotoShootUnscheduled', (arguments) {
        final photoShootId = arguments?[0] as String;
        final photoShoot = getPhotoShootById(photoShootId);
        if (photoShoot == null) {
          return;
        }
        setState(() {
          photoShoot.status = PhotoShootStatus.unbooked;
        });
      });

      await hubConnection.start();
    } catch (e) {
      // Connection failed, but we can still function without real-time updates
    }
  }

  List<TableRow> getRows(columnCount) {
    List<TableRow> rows = [];
    List<DateTime> dates = [];
    int rowCount = 0;
    for (final date in photoShootsByDate.keys) {
      if (firstDate != null && date.isBefore(firstDate!)) {
        continue;
      }
      if (photoShootsByDate[date]!.length > rowCount) {
        rowCount = photoShootsByDate[date]!.length;
      }
      if (dates.length >= columnCount) {
        break;
      }
      dates.add(date);
    }

    for (int i = 0; i < rowCount; i++) {
      // header row
      if (i == 0) {
        rows.add(
          TableRow(
            children: [
              IconButton(
                onPressed: firstDate?.isSameDay(photoShootsByDate.keys.first) ??
                        false
                    ? null
                    : () {
                        final currentIndex =
                            photoShootsByDate.keys.toList().indexOf(firstDate!);
                        setState(() {
                          firstDate =
                              photoShootsByDate.keys.toList()[currentIndex - 1];
                        });
                      },
                icon: Icon(Icons.arrow_back),
              ),
              ...dates.map((date) {
                final photoShootData = photoShootsByDate[date]!.first;
                return TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          DateFormat.Md().format(date),
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(photoShootData.nameOfShoot ?? ''),
                        Text(photoShootData.location ?? ''),
                      ],
                    ),
                  ),
                );
              }),
              IconButton(
                onPressed: !moreDatesAvailable(columnCount)
                    ? null
                    : () {
                        final currentIndex =
                            photoShootsByDate.keys.toList().indexOf(firstDate!);
                        setState(() {
                          firstDate =
                              photoShootsByDate.keys.toList()[currentIndex + 1];
                        });
                      },
                icon: Icon(Icons.arrow_forward),
              ),
            ],
          ),
        );
        continue;
      }
      rows.add(
        TableRow(
          children: [
            // blank column for the back navigation button
            const TableCell(child: SizedBox()),
            ...dates.map(
              (date) {
                if (photoShootsByDate[date]!.length < i) {
                  return const TableCell(child: SizedBox());
                }
                final photoShoot = photoShootsByDate[date]![i - 1];
                return TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: photoShoot.status != PhotoShootStatus.unbooked
                          ? null
                          : () {
                              setState(() {
                                scheduleAppointmentRequest.photoShootId =
                                    photoShoot.photoShootId;
                              });
                            },
                      child: Text(
                        DateFormat.jm().format(
                          photoShoot.dateTimeUtc!.toLocal(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // blank column for the forward navigation button
            const TableCell(child: SizedBox())
          ],
        ),
      );
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButton: isAuthenticated
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  addingAppointmentSlots = true;
                });
              },
              child: const Icon(Icons.add),
            )
          : null,
      currentScreen: ScreensEnum.contact,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          FutureBuilder(
            future: photoShootFetch,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Oops! Something went wrong.',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'We couldn\'t load the upcoming appointments. Please try again later.',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            fetchPhotoShoots();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (addingAppointmentSlots) {
                return Center(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: 300,
                      child: NewAppointmentsForm(
                        onSave: savedPhotoShoots,
                      ),
                    ),
                  ),
                );
              }

              if (photoShootsByDate.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_busy,
                          color: Constants.goldColor, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'No upcoming appointments',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'There are currently no available appointment slots. Please check back soon or contact us to schedule an appointment.',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, BookingView.route),
                        icon: const Icon(Icons.email),
                        label: const Text('Contact Us'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return LayoutBuilder(builder: (context, constraints) {
                int columnCount = 1;
                if (constraints.maxWidth > 800) {
                  columnCount = 2;
                }
                if (constraints.maxWidth > 1200) {
                  columnCount = 3;
                }
                if (constraints.maxWidth > 1600) {
                  columnCount = 4;
                }
                if (columnCount > photoShootsByDate.length) {
                  columnCount = photoShootsByDate.length;
                }
                final Map<int, TableColumnWidth> columnWidths = {};
                columnWidths[0] = const FixedColumnWidth(50);
                columnWidths[columnCount + 1] = const FixedColumnWidth(50);
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(top: 24, bottom: 24),
                          decoration: BoxDecoration(
                            color: Constants.pinkColor.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Constants.pinkColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 32,
                                color: Constants.goldColor,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Can't find a time that works for you?",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Contact us to schedule an appointment.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Constants.goldColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                    context, BookingView.route),
                                icon: const Icon(Icons.email),
                                label: const Text('Contact Us'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Table(
                          defaultColumnWidth: FixedColumnWidth(200),
                          columnWidths: columnWidths,
                          children: getRows(columnCount),
                        ),
                        AppFooter()
                      ],
                    ),
                  ),
                );
              });
            },
          ),
          StackModal(
            height: MediaQuery.of(context).size.width > 600 ? 525 : 400,
            width: MediaQuery.of(context).size.width > 600 ? 450 : 300,
            isOpen: scheduleAppointmentRequest.photoShootId != null,
            onDismiss: () {
              setState(() {
                scheduleAppointmentRequest = ScheduleAppointmentRequest();
              });
            },
            child: ScheduleAppointmentForm(
              photoShoot:
                  getPhotoShootById(scheduleAppointmentRequest.photoShootId) ??
                      PhotoShoot(),
              onSubmit: (photoShoot) {
                setState(() {
                  scheduleAppointmentRequest = ScheduleAppointmentRequest();
                });
              },
              onCancel: (photoShoot) {
                setState(() {
                  scheduleAppointmentRequest = ScheduleAppointmentRequest();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
