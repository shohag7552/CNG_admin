import 'package:appwrite_boilerplate/app/common/widgets/custom_appbar.dart';
import 'package:appwrite_boilerplate/app/common/widgets/web_top_nav.dart';
import 'package:appwrite_boilerplate/app/controllers/item_controller.dart';
import 'package:appwrite_boilerplate/app/modules/example/widgets/item_card.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Example list screen (dashboard Home tab): View → Controller → RepoInterface
/// → Repository → AppwriteService. The view only calls controller methods and
/// renders controller state. Replace with your own home screen.
class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final ItemController _controller = Get.find<ItemController>();

  @override
  void initState() {
    super.initState();
    _controller.getItems();
  }

  /// Infinite scroll: ask for the next page near the bottom.
  bool _onScroll(ScrollNotification n) {
    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
      _controller.loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = WebTopNav.isEnabled(context);
    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      // On desktop web the dashboard already shows the top nav.
      appBar: isWeb
          ? null
          : CustomAppbar(title: Constants.appName, showBackButton: false),
      body: GetBuilder<ItemController>(
        builder: (controller) {
          if (controller.isLoading && controller.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage != null && controller.items.isEmpty) {
            return _Message(
              text: controller.errorMessage!,
              actionLabel: 'retry'.tr,
              onAction: controller.getItems,
            );
          }
          if (controller.items.isEmpty) {
            return _Message(text: 'no_items_found'.tr);
          }
          return RefreshIndicator(
            onRefresh: controller.getItems,
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: WebTopNav.maxContentWidth,
                  ),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      Constants.paddingSizeDefault,
                      Constants.paddingSizeDefault,
                      Constants.paddingSizeDefault,
                      Constants.bottomNavSpace,
                    ),
                    itemCount: controller.items.length +
                        (controller.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: Constants.paddingSizeSmall),
                    itemBuilder: (context, index) {
                      if (index >= controller.items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(Constants.paddingSizeDefault),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return ItemCard(item: controller.items[index]);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Message({required this.text, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.paddingSizeLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: poppinsRegular.copyWith(
                fontSize: Constants.fontSizeDefault,
                color: context.textSecondary,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: Constants.paddingSizeDefault),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
