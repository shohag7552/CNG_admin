import 'package:appwrite/appwrite.dart';
import 'package:appwrite_boilerplate/app/appwrite/appwrite_config.dart';
import 'package:appwrite_boilerplate/app/appwrite/appwrite_service.dart';
import 'package:appwrite_boilerplate/app/models/item_model.dart';
import 'package:appwrite_boilerplate/app/modules/example/domain/repository/item_repo_interface.dart';

/// The only layer that talks to Appwrite for items. Returns models; throws on
/// failure so the controller decides what the user sees.
class ItemRepository implements ItemRepoInterface {
  final AppwriteService appwriteService;

  ItemRepository({required this.appwriteService});

  @override
  Future<List<ItemModel>> getItems({String? cursor, int limit = 20}) async {
    final res = await appwriteService.listTable(
      tableId: AppwriteConfig.itemsCollection,
      queries: [
        Query.orderDesc('\$createdAt'),
        Query.limit(limit),
        if (cursor != null) Query.cursorAfter(cursor),
      ],
    );
    return res.rows.map((r) => ItemModel.fromJson(r.data)).toList();
  }
}
