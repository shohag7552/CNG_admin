import 'dart:developer';

import 'package:appwrite_boilerplate/app/models/page_result.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:get/get.dart';

/// Shared state machine for the admin tables: first page, load-more, error and
/// empty detection. Subclasses add their filters and implement [fetchPage];
/// any filter change calls [load] to start again from page one.
abstract class PagedListController<T> extends GetxController implements GetxService {
  List<T> _items = [];
  List<T> get items => _items;

  int _total = 0;
  int get total => _total;
  bool get hasMore => _items.length < _total;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Guards against a slow older response overwriting a newer one.
  int _generation = 0;

  Future<PageResult<T>> fetchPage(int offset, int limit);

  Future<void> load() async {
    final gen = ++_generation;
    _isLoading = true;
    _errorMessage = null;
    update();
    try {
      final page = await fetchPage(0, Constants.pageSize);
      if (gen != _generation) return;
      _items = page.items;
      _total = page.total;
    } catch (e) {
      if (gen != _generation) return;
      log('Failed to load $runtimeType: $e');
      _items = [];
      _total = 0;
      _errorMessage = 'failed_to_load_data'.tr;
    }
    _isLoading = false;
    update();
  }

  Future<void> loadMore() async {
    if (!hasMore || _isLoading || _isLoadingMore) return;
    final gen = _generation;
    _isLoadingMore = true;
    update();
    try {
      final page = await fetchPage(_items.length, Constants.pageSize);
      if (gen == _generation) {
        _items = [..._items, ...page.items];
        _total = page.total;
      }
    } catch (e) {
      log('Failed to load more $runtimeType: $e');
      _errorMessage = 'failed_to_load_data'.tr;
    }
    _isLoadingMore = false;
    update();
  }
}
