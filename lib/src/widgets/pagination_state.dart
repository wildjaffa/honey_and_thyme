import 'package:flutter/foundation.dart';

import '../models/pagination_result.dart';

typedef DataFetchCallback<T> = Future<T?> Function(int page, int pageSize);

class PaginationState<T extends PaginationResult> extends ChangeNotifier {
  int _currentPage = 0;
  int _pageSize = 10;
  bool _isLoading = false;
  T? _data;
  String? _error;
  DataFetchCallback<T>? _dataFetchCallback;

  // Getters
  int get pageIndex => _currentPage;
  int get pageSize => _pageSize;
  bool get isLoading => _isLoading;
  bool get hasMorePages =>
      _data?.pageCount != null && _data!.pageCount! > _currentPage;
  T? get data => _data;
  String? get error => _error;

  // Constructor with optional data fetch callback
  PaginationState({DataFetchCallback<T>? dataFetchCallback}) {
    _dataFetchCallback = dataFetchCallback;
  }

  // Set the data fetch callback
  void setDataFetchCallback(DataFetchCallback<T> callback) {
    _dataFetchCallback = callback;
  }

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
    notifyListeners();
  }

  void setData(T? value) {
    _data = value;
  }

  void setError(String? value) {
    _error = value;
  }

  // Navigation methods
  void nextPage() {
    if (hasMorePages && !_isLoading) {
      _currentPage++;
      _loadData();
    }
  }

  void previousPage() {
    if (_currentPage > 0 && !_isLoading) {
      _currentPage--;
      _loadData();
    }
  }

  void goToPage(int page) {
    if (page >= 0 && !_isLoading) {
      _currentPage = page;
      _loadData();
    }
  }

  void reset() {
    _currentPage = 0;
    _isLoading = false;
    _error = null;
    _loadData();
  }

  void changePageSize(int newPageSize) {
    _pageSize = newPageSize;
    _currentPage = 0; // Reset to first page when page size changes
    _loadData();
  }

  // Load data using the callback
  Future<void> _loadData() async {
    if (_dataFetchCallback == null) return;

    setLoading(true);
    setError(null);

    try {
      final result = await _dataFetchCallback!(_currentPage, _pageSize);
      setData(result);
      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

  // Initial load
  Future<void> loadInitialData() async {
    await _loadData();
  }

  // Refresh data (same as reset but doesn't change page)
  Future<void> refresh() async {
    await _loadData();
  }

  // Helper methods for API calls
  Map<String, String> get queryParameters => {
        'pageSize': _pageSize.toString(),
        'pageIndex': _currentPage.toString(),
      };

  int get totalPages {
    return _data?.pageCount ?? 0;
  }
}
