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
import 'package:honey_and_thyme/src/widgets/pagination_controls.dart';
import 'package:honey_and_thyme/src/widgets/pagination_state.dart';
import 'package:honey_and_thyme/src/widgets/labeled_checkbox.dart';
import 'package:intl/intl.dart';

import '../../../utils/constants.dart';
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
  late PaginationState<PaginatedPhotoShoots> _paginationState;
  PhotoShootFilterRequest filters = PhotoShootFilterRequest(
    startDate: DateTime.now().subtract(
      const Duration(days: 7),
    ),
    statuses: [
      PhotoShootStatus.confirmed,
      PhotoShootStatus.booked,
      PhotoShootStatus.paid
    ],
    pageIndex: 0,
    pageSize: 10,
  );
  List<Product> products = [];
  List<Album> albums = [];
  Set<String> selectedPhotoShootIds = {};
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _paginationState = PaginationState<PaginatedPhotoShoots>(
      dataFetchCallback: _fetchPhotoShoots,
    );
    _paginationState.loadInitialData();
    ProductService.fetchProducts().then((value) {
      products = value;
    });
    AlbumService.fetchAlbums().then((value) {
      albums = value?.results ?? [];
    });
  }

  @override
  void dispose() {
    _paginationState.dispose();
    super.dispose();
  }

  Future<PaginatedPhotoShoots?> _fetchPhotoShoots(
      int page, int pageSize) async {
    // Convert selected statuses to list
    filters.pageIndex = page;
    filters.pageSize = pageSize;
    return PhotoShootService.fetchPhotoShoots(
      filters,
    );
  }

  void _refreshPhotoShoots() {
    _paginationState.reset();
  }

  void _applyFilters() {
    _refreshPhotoShoots();
  }

  void _clearFilters() {
    setState(() {
      filters.startDate = DateTime.now().subtract(const Duration(days: 7));
      filters.endDate = null;
      filters.statuses = [
        PhotoShootStatus.confirmed,
        PhotoShootStatus.booked,
        PhotoShootStatus.paid
      ];
    });
    _refreshPhotoShoots();
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
        _refreshPhotoShoots();
        submitting = false;
      });
      final awaited = _paginationState.data;

      if (photoShoot.status == PhotoShootStatus.delivered) {
        showSuccess(
            context, 'Shoot saved successfully and marked as delivered');
        photoShoot = PhotoShoot();
        return;
      }

      setState(() {
        photoShoot = PhotoShoot();
        editing = false;
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
        _refreshPhotoShoots();
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
        reservationCode: photoShoot.reservationCode!,
      );

      final createOrderResponse =
          await PhotoShootService.createPhotoShootPayment(createOrderRequest);

      final captureOrderRequest = PhotoShootPaymentCaptureRequest(
        amountToBeCharged: photoShoot.paymentRemaining!,
        externalOrderId: photoShoot.photoShootId!,
        paymentProcessor: PaymentProcessors.external,
        reservationCode: photoShoot.reservationCode!,
        invoiceId: createOrderResponse.invoiceId,
      );
      await PhotoShootService.capturePhotoShootPayment(captureOrderRequest);

      setState(() {
        editing = false;
        _refreshPhotoShoots();
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

  void toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode) {
        selectedPhotoShootIds.clear();
      }
    });
  }

  void togglePhotoShootSelection(String photoShootId) {
    setState(() {
      if (selectedPhotoShootIds.contains(photoShootId)) {
        selectedPhotoShootIds.remove(photoShootId);
      } else {
        selectedPhotoShootIds.add(photoShootId);
      }
    });
  }

  void selectAllPhotoShoots() {
    setState(() {
      final photoShootsData = _paginationState.data;
      if (photoShootsData?.results != null) {
        selectedPhotoShootIds.addAll(
          photoShootsData!.results!.map((shoot) => shoot.photoShootId!).toSet(),
        );
      }
    });
  }

  void deselectAllPhotoShoots() {
    setState(() {
      selectedPhotoShootIds.clear();
    });
  }

  void bulkCancelPhotoShoots() async {
    if (selectedPhotoShootIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Cancel Selected Shoots"),
        content: Text(
            "Are you sure you want to cancel ${selectedPhotoShootIds.length} selected shoot(s)?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Never Mind"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performBulkCancel();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<void> _performBulkCancel() async {
    try {
      setState(() {
        submitting = true;
      });

      final selectedCount = selectedPhotoShootIds.length;
      final selectedIds = selectedPhotoShootIds.toList();

      // Cancel each selected photo shoot
      for (String photoShootId in selectedIds) {
        await PhotoShootService.deletePhotoShoot(photoShootId);
      }

      setState(() {
        selectedPhotoShootIds.clear();
        isSelectionMode = false;
        _refreshPhotoShoots();
        submitting = false;
      });

      showSuccess(context, '$selectedCount shoot(s) cancelled successfully');
    } catch (e) {
      setState(() {
        submitting = false;
        showError(context,
            'There was a problem cancelling the shoots. Please try again.');
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentScreen: ScreensEnum.admin,
      child: Authenticate(
        child: Center(
          child: SizedBox(
            width: 300,
            child: ListenableBuilder(
              listenable: _paginationState,
              builder: (context, child) {
                if (_paginationState.isLoading || submitting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_paginationState.error != null) {
                  return Text('Error: ${_paginationState.error}');
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

                final photoShootsData = _paginationState.data;

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: (photoShootsData?.results?.length ?? 0) + 1,
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
                              endWidget: Row(
                                children: [
                                  if (isSelectionMode) ...[
                                    if (selectedPhotoShootIds.isNotEmpty)
                                      IconButton(
                                        onPressed: bulkCancelPhotoShoots,
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        tooltip:
                                            'Cancel ${selectedPhotoShootIds.length} Selected',
                                      ),
                                    const SizedBox(width: 8),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: toggleSelectionMode,
                                      icon: const Icon(Icons.cancel),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  FilterPopoverButton(
                                    filters: filters,
                                    onApply: () {
                                      _applyFilters();
                                    },
                                    onClear: () {
                                      _clearFilters();
                                    },
                                    onChange: () {
                                      setState(() {});
                                      ();
                                    },
                                  ),
                                ],
                              ),
                            );
                          }

                          final shoot = photoShootsData?.results?[index - 1];
                          return GestureDetector(
                            onLongPress: () {
                              if (!isSelectionMode) {
                                setState(() {
                                  isSelectionMode = true;
                                  selectedPhotoShootIds
                                      .add(shoot.photoShootId!);
                                });
                              }
                            },
                            child: ListTile(
                              leading: isSelectionMode
                                  ? Checkbox(
                                      value: selectedPhotoShootIds
                                          .contains(shoot!.photoShootId),
                                      onChanged: (value) {
                                        togglePhotoShootSelection(
                                            shoot.photoShootId!);
                                      },
                                    )
                                  : Icon(
                                      shoot!.status ==
                                              PhotoShootStatus.confirmed
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
                              trailing:
                                  Text(shoot.responsiblePartyName.toString()),
                              onTap: () {
                                if (isSelectionMode) {
                                  togglePhotoShootSelection(
                                      shoot.photoShootId!);
                                } else {
                                  setState(() {
                                    editing = true;
                                    photoShoot = shoot;
                                  });
                                }
                              },
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                      ),
                    ),

                    // Pagination controls
                    if (photoShootsData?.results?.isNotEmpty == true)
                      PaginationControls<PaginatedPhotoShoots>(
                        paginationState: _paginationState,
                        onUpdate: (paginationState) {
                          _fetchPhotoShoots(paginationState.pageIndex,
                              paginationState.pageSize);
                        },
                      ),
                  ],
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

class FilterPopoverButton extends StatefulWidget {
  final PhotoShootFilterRequest filters;
  final VoidCallback onApply;
  final VoidCallback onClear;
  final VoidCallback onChange;
  const FilterPopoverButton({
    super.key,
    required this.filters,
    required this.onApply,
    required this.onClear,
    required this.onChange,
  });

  @override
  State<FilterPopoverButton> createState() => _FilterPopoverButtonState();
}

class _FilterPopoverButtonState extends State<FilterPopoverButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.filter_alt, color: Constants.goldColor),
      tooltip: 'Show Filters',
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                  content: SizedBox(
                    width: 320,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Filters',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    widget.onClear();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Clear All'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    widget.onApply();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Apply'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Start Date'),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () async {
                                      final value = await showDatePicker(
                                        context: context,
                                        initialDate: widget.filters.startDate ??
                                            DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2050),
                                      );
                                      if (value != null) {
                                        widget.filters.startDate = value;
                                        setDialogState(() {});
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              widget.filters.startDate == null
                                                  ? 'Select start date'
                                                  : DateFormat.yMd().format(
                                                      widget
                                                          .filters.startDate!),
                                            ),
                                          ),
                                          const Icon(Icons.calendar_today,
                                              size: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('End Date'),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () async {
                                      final value = await showDatePicker(
                                        context: context,
                                        initialDate: widget.filters.endDate ??
                                            DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2050),
                                      );
                                      if (value != null) {
                                        widget.filters.endDate = value;
                                        setDialogState(() {});
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              widget.filters.endDate == null
                                                  ? 'Select end date'
                                                  : DateFormat.yMd().format(
                                                      widget.filters.endDate!),
                                            ),
                                          ),
                                          const Icon(Icons.calendar_today,
                                              size: 16),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Status',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PhotoShootStatus.values.map((status) {
                            return SizedBox(
                              width: 120,
                              child: LabeledCheckbox(
                                label: _getStatusDisplayName(status),
                                value: widget.filters.statuses.contains(status),
                                onChanged: (value) {
                                  if (value == true) {
                                    if (!(widget.filters.statuses
                                        .contains(status))) {
                                      widget.filters.statuses.add(status);
                                    }
                                  } else {
                                    widget.filters.statuses.remove(status);
                                  }
                                  setDialogState(() {});
                                  widget.onChange();
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _getStatusDisplayName(PhotoShootStatus status) {
    switch (status) {
      case PhotoShootStatus.unbooked:
        return 'Unbooked';
      case PhotoShootStatus.scheduled:
        return 'Scheduled';
      case PhotoShootStatus.booked:
        return 'Booked';
      case PhotoShootStatus.confirmed:
        return 'Confirmed';
      case PhotoShootStatus.paid:
        return 'Paid';
      case PhotoShootStatus.delivered:
        return 'Delivered';
      case PhotoShootStatus.deleted:
        return 'Deleted';
    }
  }
}
