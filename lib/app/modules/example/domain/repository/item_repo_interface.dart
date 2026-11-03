import 'package:appwrite_boilerplate/app/models/item_model.dart';

/// The controller depends on this abstraction, never on [ItemRepository].
abstract class ItemRepoInterface {
  /// One page of items, newest first. Pass the last loaded item's id as
  /// [cursor] to get the next page.
  Future<List<ItemModel>> getItems({String? cursor, int limit});
}
