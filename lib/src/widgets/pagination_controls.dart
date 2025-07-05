import 'package:flutter/material.dart';
import '../models/pagination_result.dart';
import 'pagination_state.dart';

class PaginationControls<T extends PaginationResult> extends StatelessWidget {
  final PaginationState<T> paginationState;
  final List<int> availablePageSizes;
  final void Function(PaginationState<T>) onUpdate;
  const PaginationControls({
    super.key,
    required this.paginationState,
    this.availablePageSizes = const [5, 10, 20, 50],
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: paginationState,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Page size selector on top row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Show: ',
                    style: TextStyle(fontSize: 14),
                  ),
                  DropdownButton<int>(
                    value: paginationState.pageSize,
                    onChanged: paginationState.isLoading
                        ? null
                        : (int? newValue) {
                            if (newValue != null) {
                              paginationState.changePageSize(newValue);
                              onUpdate(paginationState);
                            }
                          },
                    items: availablePageSizes
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value'),
                      );
                    }).toList(),
                  ),
                  const Text(
                    ' per page',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              // Pagination controls on bottom row (only show if there are multiple pages)
              if (paginationState.totalPages > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: (paginationState.pageIndex > 0 &&
                                !paginationState.isLoading)
                            ? paginationState.previousPage
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Page ${paginationState.pageIndex + 1} of ${paginationState.totalPages}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: (paginationState.pageIndex + 1 <
                                    paginationState.totalPages &&
                                !paginationState.isLoading)
                            ? paginationState.nextPage
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
