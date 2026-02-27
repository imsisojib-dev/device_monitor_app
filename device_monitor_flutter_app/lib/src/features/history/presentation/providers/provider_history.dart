import 'package:device_monitor/src/core/data/models/api_filter.dart';
import 'package:device_monitor/src/core/data/models/api_filter_request_builder.dart';
import 'package:device_monitor/src/core/di/di_container.dart';
import 'package:device_monitor/src/core/enums/e_loading.dart';
import 'package:device_monitor/src/core/enums/e_sort_order.dart';
import 'package:device_monitor/src/features/history/domain/usecases/usecase_fetch_vitals.dart';
import 'package:device_monitor/src/core/domain/entities/vitals_entity.dart';
import 'package:flutter/foundation.dart';

class ProviderHistory extends ChangeNotifier {
  List<VitalsEntity> _logs = [];
  ApiFilterRequest filter = ApiFilterRequestBuilder().build();
  ELoading? _loading;
  String? _error;
  String? _deviceId;

  // Stores logs for up to 3 pages (previous, current, next)
  final Map<int, List<VitalsEntity>> _pageCache = {};
  int _currentPage = 0;
  int _limit = 20;
  bool _hasMoreNext = true;
  bool _hasMorePrevious = false;

  //getters
  bool get hasMoreNext => _hasMoreNext;

  bool get hasMorePrevious => _hasMorePrevious;

  int get currentPage => _currentPage;

  List<VitalsEntity> get logs {
    // Return logs from all cached pages in order
    _logs.clear();
    final pages = _pageCache.keys.toList()..sort();

    for (var page in pages) {
      _logs.addAll(_pageCache[page] ?? []);
    }

    return _logs;
  }

  ELoading? get loading => _loading;

  String? get error => _error;

  //setters
  set loading(ELoading? state) {
    _loading = state;
    notifyListeners();
  }

  /// Initialize with first load
  Future<void> loadHistory({required String deviceId, int limit = 20}) async {
    _deviceId = deviceId;
    _limit = limit;
    _currentPage = 0;
    _pageCache.clear();
    _error = null;
    _hasMoreNext = true;
    _hasMorePrevious = false;
    loading = ELoading.loading;

    try {
      await _fetchPage(0);
    } catch (e) {
      _error = 'Failed to load history: ${e.toString()}';
    } finally {
      loading = null;
      notifyListeners();
    }
  }

  /// Load next page (scroll down)
  Future<void> loadNextPage() async {
    if (_loading == ELoading.fetchingNextPage || !_hasMoreNext || _deviceId == null) return;

    final nextPage = _currentPage + 1;

    // Check if already cached
    if (_pageCache.containsKey(nextPage)) {
      _currentPage = nextPage;
      _maintainThreePageWindow();
      notifyListeners();
      return;
    }

    loading = ELoading.fetchingNextPage;
    _error = null;

    try {
      await _fetchPage(nextPage);
      _currentPage = nextPage;
      _maintainThreePageWindow();
    } catch (e) {
      _error = 'Failed to load next page: ${e.toString()}';
    } finally {
      loading = null;
      notifyListeners();
    }
  }

  /// Load previous page (scroll up)
  Future<void> loadPreviousPage() async {
    if (_loading == ELoading.fetchingPreviousPage || _currentPage <= 0 || _deviceId == null) return;

    final previousPage = _currentPage - 1;

    // Check if already cached
    if (_pageCache.containsKey(previousPage)) {
      _currentPage = previousPage;
      _maintainThreePageWindow();
      notifyListeners();
      return;
    }

    loading = ELoading.fetchingPreviousPage;
    _error = null;

    try {
      await _fetchPage(previousPage);
      _currentPage = previousPage;
      _maintainThreePageWindow();
    } catch (e) {
      _error = 'Failed to load previous page: ${e.toString()}';
    } finally {
      loading = null;
      notifyListeners();
    }
  }

  /// Maintain only 3 pages in memory (previous, current, next)
  void _maintainThreePageWindow() {
    final pagesToKeep = <int>{
      if (_currentPage > 0) _currentPage - 1, // Previous page
      _currentPage, // Current page
      _currentPage + 1, // Next page
    };

    _pageCache.removeWhere((page, _) => !pagesToKeep.contains(page));
  }

  /// Fetch a specific page from API
  Future<void> _fetchPage(int page) async {
    if (_deviceId == null) return;

    final filter = ApiFilterRequestBuilder().setPage(page).setLimit(_limit).setDeviceId(_deviceId!).addSort('timestamp',order: ESortOrder.desc).build();

    final result = await UseCaseFetchVitals(repositoryVitals: sl()).execute(filter);

    result.fold(
      (error) {
        _error = error.message;
      },
      (response) {
        final data = response.data ?? [];
        _pageCache[page] = data;

        // Update pagination flags
        _hasMoreNext = data.length >= _limit;
        _hasMorePrevious = page > 0;
      },
    );
  }

  Future<void> refresh() async {
    if (_deviceId == null) return;

    final currentPageBackup = _currentPage;
    _pageCache.clear();
    _error = null;
    loading = ELoading.loading;

    try {
      // Reload current page and adjacent pages
      await _fetchPage(currentPageBackup);

      if (currentPageBackup > 0) {
        await _fetchPage(currentPageBackup - 1);
      }

      if (_hasMoreNext) {
        await _fetchPage(currentPageBackup + 1);
      }

      _currentPage = currentPageBackup;
    } catch (e) {
      _error = 'Failed to refresh: ${e.toString()}';
    } finally {
      loading = null;
      notifyListeners();
    }
  }
}
