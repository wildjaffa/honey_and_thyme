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
import '../../widgets/pagination_controls.dart';
import '../../widgets/pagination_state.dart';
import '../admin.dart';
import '../authenticate.dart';

class BookingsList extends StatefulWidget {
  const BookingsList({super.key});

  @override
  State<BookingsList> createState() => _BookingsListState();
}

class _BookingsListState extends State<BookingsList> {
  final PaginationState _paginationState = PaginationState();
  late Future<PaginatedPhotoShoots?> photoShoots;
  List<Product> products = [];
  bool editing = false;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _loadPhotoShoots();
    ProductService.fetchProducts().then((value) {
      products = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadPhotoShoots() {
    photoShoots = PhotoShootService.fetchPhotoShoots(
      PhotoShootFilterRequest(
        startDate: DateTime.now().toUtc(),
        bookStatusFilter: PhotoShootBookStatusFilter.unbooked,
        page: _paginationState.currentPage,
        pageSize: _paginationState.pageSize,
      ),
    );
  }

  void _nextPage() {
    _paginationState.nextPage();
    setState(() {
      _loadPhotoShoots();
    });
  }

  void _previousPage() {
    _paginationState.previousPage();
    setState(() {
      _loadPhotoShoots();
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
                if (snapshot.data == null) {
                  return const Text('No bookings found');
                }

                final photoShootsData = snapshot.data!;

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: (photoShootsData.results?.length ?? 0) + 1,
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
                            );
                          }

                          final shoot = photoShootsData.results![index - 1];
                          return ListTile(
                            title: Text(
                                '${DateFormat.yMd().add_jm().format(shoot.dateTimeUtc!.toLocal())} - ${DateFormat.jm().format(shoot.endDateTimeUtc!.toLocal())}'),
                            subtitle: Text(shoot.nameOfShoot!),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                      ),
                    ),
                    // Pagination controls
                    if (photoShootsData.results?.isNotEmpty == true)
                      PaginationControls(
                        currentPage: _paginationState.currentPage,
                        totalPages: photoShootsData.pageCount ?? 1,
                        onPreviousPage: _previousPage,
                        onNextPage: _nextPage,
                        isLoading: _paginationState.isLoading,
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
