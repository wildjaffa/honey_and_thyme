import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/models/photo_shoot_filter_request.dart';
import 'package:intl/intl.dart';

import '../../models/enums/screens.dart';
import '../../models/photo_shoot.dart';
import '../../models/product.dart';
import '../../services/photo_shoot_service.dart';
import '../../services/product_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/back_or_add_buttons.dart';
import '../admin.dart';
import '../authenticate.dart';

class BookingsList extends StatefulWidget {
  const BookingsList({super.key});

  @override
  State<BookingsList> createState() => _BookingsListState();
}

class _BookingsListState extends State<BookingsList> {
  late Future<List<PhotoShoot>> photoShoots;
  List<Product> products = [];
  bool editing = false;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    photoShoots = PhotoShootService.fetchPhotoShoots(PhotoShootFilterRequest(
      startDate: DateTime.now().toUtc(),
      bookStatusFilter: PhotoShootBookStatusFilter.unbooked,
    ));
    ProductService.fetchProducts().then((value) {
      products = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentScreen: ScreensEnum.admin,
      child: Authenticate(
        child: Center(
          child: SizedBox(
            width: 300,
            child: FutureBuilder(
              future: photoShoots,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    submitting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                // if (editing) {
                //   return PhotoShootForm(
                //     products: products,
                //     photoShoot: photoShoot,
                //     albums: albums,
                //     onCancel: () {
                //       setState(() {
                //         editing = false;
                //         photoShoot = PhotoShoot();
                //       });
                //     },
                //     onSave: savePhotoShoot,
                //     onDelete: confirmDelete,
                //     onMarkPaid: confirmMarkPaid,
                //   );
                // }

                return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data!.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return BackOrAddButtons(
                        addText: 'Add Shoot',
                        backRoute: AdminView.route,
                        onAdd: () {
                          setState(() {
                            editing = true;
                          });
                        },
                        // endWidget: PopupMenuButton(
                        //   child: const Icon(Icons.filter_alt),
                        //   itemBuilder: (context) {
                        //     return [
                        //       PopupMenuItem(
                        //         child: ListTile(
                        //           title: Text(
                        //               'Start Date: ${filters.startDate == null ? '' : DateFormat.yMd().add_jm().format(filters.startDate!.toLocal())}'),
                        //           onTap: () {
                        //             showDatePicker(
                        //               context: context,
                        //               initialDate:
                        //                   filters.startDate ?? DateTime.now(),
                        //               firstDate: DateTime(2020),
                        //               lastDate: DateTime(2050),
                        //             ).then((value) {
                        //               setState(() {
                        //                 filters.startDate = value;
                        //                 photoShoots =
                        //                     PhotoShootService.fetchPhotoShoots(
                        //                   filters,
                        //                 );
                        //               });
                        //               Navigator.pop(context);
                        //             });
                        //           },
                        //         ),
                        //       ),
                        //       PopupMenuItem(
                        //         child: ListTile(
                        //           title: Text(
                        //               'End Date: ${filters.endDate == null ? '' : DateFormat.yMd().add_jm().format(filters.endDate!.toLocal())}'),
                        //           onTap: () {
                        //             showDatePicker(
                        //               context: context,
                        //               initialDate:
                        //                   filters.endDate ?? DateTime.now(),
                        //               firstDate: DateTime(2020),
                        //               lastDate: DateTime(2050),
                        //             ).then((value) {
                        //               setState(() {
                        //                 filters.endDate = value;
                        //                 photoShoots =
                        //                     PhotoShootService.fetchPhotoShoots(
                        //                   filters,
                        //                 );
                        //               });
                        //               Navigator.pop(context);
                        //             });
                        //           },
                        //         ),
                        //       ),
                        //       PopupMenuItem(
                        //         child: ListTile(
                        //           title: Text(
                        //               'Exclude Paid Shoots: ${filters.excludePaidShoots == null ? '' : filters.excludePaidShoots.toString()}'),
                        //           onTap: () {
                        //             setState(() {
                        //               filters.excludePaidShoots =
                        //                   filters.excludePaidShoots == null
                        //                       ? true
                        //                       : !filters.excludePaidShoots!;
                        //               photoShoots =
                        //                   PhotoShootService.fetchPhotoShoots(
                        //                 filters,
                        //               );
                        //             });
                        //             Navigator.pop(context);
                        //           },
                        //         ),
                        //       ),
                        //       PopupMenuItem(
                        //         child: ListTile(
                        //           title: Text(
                        //               'Exclude Delivered Shoots: ${filters.excludeDeliveredShoots}'),
                        //           onTap: () {
                        //             setState(() {
                        //               filters.excludeDeliveredShoots =
                        //                   filters.excludeDeliveredShoots == null
                        //                       ? true
                        //                       : !filters
                        //                           .excludeDeliveredShoots!;
                        //               photoShoots =
                        //                   PhotoShootService.fetchPhotoShoots(
                        //                       filters);
                        //             });
                        //             Navigator.pop(context);
                        //           },
                        //         ),
                        //       ),
                        //     ];
                        //   },
                        // ),
                      );
                    }

                    final shoot = snapshot.data![index - 1];
                    return ListTile(
                      // leading: Icon(
                      //   shoot.isConfirmed == true ? Icons.check_circle : null,
                      //   color: shoot.isConfirmed == true &&
                      //           (shoot.paymentRemaining ?? 0) <= 0
                      //       ? Colors.green
                      //       : Colors.black,
                      // ),
                      title: Text(
                          '${DateFormat.yMd().add_jm().format(shoot.dateTimeUtc!.toLocal())} - ${DateFormat.jm().format(shoot.endDateTimeUtc!.toLocal())}'),
                      subtitle: Text(shoot.nameOfShoot!),
                      // trailing: Text(shoot.responsiblePartyName.toString()),
                      // onTap: () {
                      //   setState(() {
                      //     editing = true;
                      //     photoShoot = shoot;
                      //   });
                      // },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
