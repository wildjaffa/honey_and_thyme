class PaginationState {
  int _currentPage = 0;
  int _pageSize = 2;
  bool _isLoading = false;
  bool _hasMorePages = true;

  // Getters
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get isLoading => _isLoading;
  bool get hasMorePages => _hasMorePages;

  // Methods that update state without triggering listeners
  void setCurrentPage(int value) {
    _currentPage = value;
  }

  void setPageSize(int value) {
    _pageSize = value;
    _currentPage = 0; // Reset to first page when page size changes
  }

  void setLoading(bool value) {
    _isLoading = value;
  }

  void setHasMorePages(bool value) {
    _hasMorePages = value;
  }

  // Navigation methods
  void nextPage() {
    if (_hasMorePages && !_isLoading) {
      _currentPage++;
    }
  }

  void previousPage() {
    if (_currentPage > 0 && !_isLoading) {
      _currentPage--;
    }
  }

  void goToPage(int page) {
    if (page >= 0 && !_isLoading) {
      _currentPage = page;
    }
  }

  void reset() {
    _currentPage = 0;
    _hasMorePages = true;
    _isLoading = false;
  }

  void updatePaginationInfo(int itemsReceived) {
    _hasMorePages = itemsReceived == _pageSize;
  }

  // Helper methods for API calls
  Map<String, String> get queryParameters => {
        'pageSize': _pageSize.toString(),
        'pageIndex': _currentPage.toString(),
      };

  int get totalPages {
    if (!_hasMorePages) {
      return _currentPage + 1;
    }
    // If we have more pages, we don't know the total, so estimate
    return _currentPage + 2;
  }

  // No dispose method needed since we're not using ChangeNotifier
}
