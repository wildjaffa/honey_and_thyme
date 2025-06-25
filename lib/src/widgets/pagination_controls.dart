import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final bool isLoading;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPreviousPage,
    this.onNextPage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (currentPage > 0 && !isLoading) ? onPreviousPage : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Page ${currentPage + 1} of $totalPages',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: (currentPage + 1 < totalPages && !isLoading)
                ? onNextPage
                : null,
          ),
        ],
      ),
    );
  }
}
