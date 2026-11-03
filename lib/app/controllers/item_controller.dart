import 'dart:developer';

import 'package:appwrite_boilerplate/app/models/item_model.dart';
import 'package:appwrite_boilerplate/app/modules/example/domain/repository/item_repo_interface.dart';
import 'package:get/get.dart';

/// Example controller: owns loading / error / data / pagination state for the
/// item list. Copy this shape for every list feature.
class ItemController extends GetxController implements GetxService {
  final ItemRepoInterface itemRepoInterface;

  ItemController({required this.itemRepoInterface});

  static const int pageSize = 20;

  List<ItemModel> _items = [];
  List<ItemModel> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// First page (initial load, pull-to-refresh, retry).
  Future<void> getItems() async {
    _isLoading = true;
    _errorMessage = null;
    update();
    try {
      _items = await itemRepoInterface.getItems(limit: pageSize);
      _hasMore = _items.length == pageSize;
    } catch (e) {
      log('Failed to load items: $e');
      _errorMessage = 'failed_to_load_items'.tr;
    }
    _isLoading = false;
    update();
  }

  /// Next page, appended. No-op while a load runs or when nothing is left.
  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore || _items.isEmpty) return;
    _isLoadingMore = true;
    update();
    try {
      final next = await itemRepoInterface.getItems(
        cursor: _items.last.id,
        limit: pageSize,
      );
      _items = [..._items, ...next];
      _hasMore = next.length == pageSize;
    } catch (e) {
      log('Failed to load more items: $e');
    }
    _isLoadingMore = false;
    update();
  }
}
