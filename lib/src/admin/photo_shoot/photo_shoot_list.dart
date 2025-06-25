import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/admin/authenticate.dart';
import 'package:honey_and_thyme/src/admin/photo_shoot/photo_shoot_form.dart';
import 'package:honey_and_thyme/src/models/album.dart';
import 'package:honey_and_thyme/src/models/enums/photo_shoot_status.dart';
import 'package:honey_and_thyme/src/models/enums/screens.dart';
import 'package:honey_and_thyme/src/models/photo_shoot.dart';
import 'package:honey_and_thyme/src/models/photo_shoot_filter_request.dart';
import 'package:honey_and_thyme/src/models/photo_shoot_payment_capture_request.dart';
import 'package:honey_and_thyme/src/services/album_service.dart';
import 'package:honey_and_thyme/src/services/photo_shoot_service.dart';
import 'package:honey_and_thyme/src/widgets/app_scaffold.dart';
import 'package:intl/intl.dart';

import '../../../utils/snackbar_utils.dart';
import '../../models/create_photo_shoot_payment_request.dart';
import '../../models/enums/payment_processors.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/back_or_add_buttons.dart';
import '../admin.dart';

class PhotoShootList extends StatefulWidget {
  const PhotoShootList({
    super.key,
  });

  static const String route = '/photo-shoots';

  @override
  State<PhotoShootList> createState() => _PhotoShootListState();
}

class _PhotoShootListState extends State<PhotoShootList> {
  PhotoShootFilterRequest filters = PhotoShootFilterRequest(
    startDate: DateTime.now().subtract(
      const Duration(days: 7),
    ),
    excludeDeliveredShoots: true,
  );
  List<Product> products = [];
  List<Album> albums = [];
  late Future<PaginatedPhotoShoots?> photoShoots;

  @override
  void initState() {
    super.initState();
    photoShoots = PhotoShootService.fetchPhotoShoots(filters);
    ProductService.fetchProducts().then((value) {
      products = value;
    });
    AlbumService.fetchAlbums().then((value) {
      albums = value?.results ?? [];
    });
  }

  PhotoShoot photoShoot = PhotoShoot();
  bool editing = false;
  bool submitting = false;

  void savePhotoShoot() async {
    try {
      setState(() {
        submitting = true;
      });

      if (photoShoot.photoShootId == null) {
        await PhotoShootService.createPhotoShoot(photoShoot);
      } else {
        await PhotoShootService.updatePhotoShoot(photoShoot);
      }

      setState(() {
        photoShoots = PhotoShootService.fetchPhotoShoots(filters);
        submitting = false;
      });
      final awaited = await photoShoots;

      if (photoShoot.status == PhotoShootStatus.delivered) {
        showSuccess(
            context, 'Shoot saved successfully and marked as delivered');
        editing = false;
        photoShoot = PhotoShoot();
        return;
      }

      final updated = awaited?.results?.firstWhere(
          (element) => element.photoShootId == photoShoot.photoShootId);

      setState(() {
        photoShoot = updated ?? PhotoShoot();
      });
      showSuccess(context, 'Shoot saved successfully');
    } catch (e) {
      setState(() {
        submitting = false;
        showError(
            context, 'There was a problem saving the shoot. Please try again.');
      });
      print(e);
    }
  }

  void deletePhotoShoot() async {
    try {
      setState(() {
        submitting = true;
      });

      await PhotoShootService.deletePhotoShoot(photoShoot.photoShootId!);

      setState(() {
        editing = false;
        photoShoots = PhotoShootService.fetchPhotoShoots(filters);
        submitting = false;
        photoShoot = PhotoShoot();
      });
      showSuccess(context, 'Shoot cancelled successfully');
    } catch (e) {
      setState(() {
        submitting = false;
        showError(context,
            'There was a problem deleting the shoot. Please try again.');
      });
      print(e);
    }
  }

  void markAsPaid() async {
    try {
      setState(() {
        submitting = true;
      });
      final createOrderRequest = CreatePhotoShootPaymentRequest(
        amount: photoShoot.paymentRemaining!,
        description: 'Admin Payment',
        paymentProcessorEnum: PaymentProcessors.external,
        photoShootId: photoShoot.photoShootId!,
      );

      final createOrderResponse =
          await PhotoShootService.createPhotoShootPayment(createOrderRequest);

      final captureOrderRequest = PhotoShootPaymentCaptureRequest(
        amountToBeCharged: photoShoot.paymentRemaining!,
        externalOrderId: photoShoot.photoShootId!,
        paymentProcessor: PaymentProcessors.external,
        photoShootId: photoShoot.photoShootId!,
        invoiceId: createOrderResponse.invoiceId,
      );
      await PhotoShootService.capturePhotoShootPayment(captureOrderRequest);

      setState(() {
        editing = false;
        photoShoots = PhotoShootService.fetchPhotoShoots(filters);
        submitting = false;
        photoShoot = PhotoShoot();
      });
      showSuccess(context, 'Shoot marked as paid');
    } catch (e) {
      setState(() {
        submitting = false;
        showError(context,
            'There was a problem marking the shoot as paid. Please try again.');
      });
      print(e);
    }
  }

  void confirmMarkPaid() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Mark Paid"),
        content:
            const Text("Are you sure you want to mark this shoot as paid?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Never Mind"),
          ),
          TextButton(
            onPressed: () {
              markAsPaid();
              Navigator.of(context).pop();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Cancel"),
        content: const Text("Are you sure you want to cancel this shoot?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Never Mind"),
          ),
          TextButton(
            onPressed: () {
              deletePhotoShoot();
              Navigator.of(context).pop();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
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

                if (editing) {
                  return PhotoShootForm(
                    products: products,
                    photoShoot: photoShoot,
                    onCancel: () {
                      setState(() {
                        editing = false;
                        photoShoot = PhotoShoot();
                      });
                    },
                    onSave: savePhotoShoot,
                    onDelete: confirmDelete,
                    onMarkPaid: confirmMarkPaid,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data!.results!.length + 1,
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
                        endWidget: PopupMenuButton(
                          child: const Icon(Icons.filter_alt),
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                child: ListTile(
                                  title: Text(
                                      'Start Date: ${filters.startDate == null ? '' : DateFormat.yMd().add_jm().format(filters.startDate!.toLocal())}'),
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate:
                                          filters.startDate ?? DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2050),
                                    ).then((value) {
                                      setState(() {
                                        filters.startDate = value;
                                        photoShoots =
                                            PhotoShootService.fetchPhotoShoots(
                                          filters,
                                        );
                                      });
                                      Navigator.pop(context);
                                    });
                                  },
                                ),
                              ),
                              PopupMenuItem(
                                child: ListTile(
                                  title: Text(
                                      'End Date: ${filters.endDate == null ? '' : DateFormat.yMd().add_jm().format(filters.endDate!.toLocal())}'),
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate:
                                          filters.endDate ?? DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2050),
                                    ).then((value) {
                                      setState(() {
                                        filters.endDate = value;
                                        photoShoots =
                                            PhotoShootService.fetchPhotoShoots(
                                          filters,
                                        );
                                      });
                                      Navigator.pop(context);
                                    });
                                  },
                                ),
                              ),
                              PopupMenuItem(
                                child: ListTile(
                                  title: Text(
                                      'Exclude Paid Shoots: ${filters.excludePaidShoots == null ? '' : filters.excludePaidShoots.toString()}'),
                                  onTap: () {
                                    setState(() {
                                      filters.excludePaidShoots =
                                          filters.excludePaidShoots == null
                                              ? true
                                              : !filters.excludePaidShoots!;
                                      photoShoots =
                                          PhotoShootService.fetchPhotoShoots(
                                        filters,
                                      );
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              PopupMenuItem(
                                child: ListTile(
                                  title: Text(
                                      'Exclude Delivered Shoots: ${filters.excludeDeliveredShoots}'),
                                  onTap: () {
                                    setState(() {
                                      filters.excludeDeliveredShoots =
                                          filters.excludeDeliveredShoots == null
                                              ? true
                                              : !filters
                                                  .excludeDeliveredShoots!;
                                      photoShoots =
                                          PhotoShootService.fetchPhotoShoots(
                                              filters);
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ];
                          },
                        ),
                      );
                    }

                    final shoot = snapshot.data!.results![index - 1];
                    return ListTile(
                      leading: Icon(
                        shoot.status == PhotoShootStatus.confirmed
                            ? Icons.check_circle
                            : null,
                        color: (shoot.paymentRemaining ?? 0) <= 0
                            ? Colors.green
                            : Colors.black,
                      ),
                      title: Text(shoot.nameOfShoot!),
                      subtitle: Text(DateFormat.yMd()
                          .add_jm()
                          .format(shoot.dateTimeUtc!.toLocal())),
                      trailing: Text(shoot.responsiblePartyName.toString()),
                      onTap: () {
                        setState(() {
                          editing = true;
                          photoShoot = shoot;
                        });
                      },
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

class PhotoShootFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? excludePaidShoots;
  final bool excludeDelivered;

  PhotoShootFilters({
    this.startDate,
    this.endDate,
    this.excludePaidShoots,
    this.excludeDelivered = false,
  });
}
