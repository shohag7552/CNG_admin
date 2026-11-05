import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminColumn {
  final String label;

  /// Preferred width; columns grow proportionally when there is spare room and
  /// the table scrolls horizontally when there is not.
  final double width;

  const AdminColumn(this.label, this.width);
}

class AdminTableRow {
  final List<Widget> cells;
  final VoidCallback? onTap;

  const AdminTableRow({required this.cells, this.onTap});
}

/// Plain-widget data table (no table package): header, rows, optional tap.
class AdminTable extends StatelessWidget {
  final List<AdminColumn> columns;
  final List<AdminTableRow> rows;

  const AdminTable({super.key, required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    final preferred = columns.fold<double>(0, (a, c) => a + c.width);
    final border = context.textLight.withValues(alpha: 0.2);
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(Constants.radiusCard),
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(builder: (context, box) {
        final width = box.maxWidth > preferred ? box.maxWidth : preferred;
        final scale = width / preferred;
        Widget line(List<Widget> cells, double height) => SizedBox(
              height: height,
              child: Row(
                children: [
                  for (var i = 0; i < columns.length; i++)
                    SizedBox(
                      width: columns[i].width * scale,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Constants.paddingSizeSmall),
                        child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: cells[i]),
                      ),
                    ),
                ],
              ),
            );
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Column(
              children: [
                Container(
                  color: context.textLight.withValues(alpha: 0.08),
                  child: line([
                    for (final c in columns)
                      Text(c.label,
                          style: poppinsBold.copyWith(
                              fontSize: Constants.fontSizeSmall,
                              color: context.textSecondary)),
                  ], Constants.tableHeaderHeight),
                ),
                for (final r in rows) ...[
                  Divider(height: 1, color: border),
                  InkWell(
                    onTap: r.onTap,
                    child: line(r.cells, Constants.tableRowHeight),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Ellipsised single-line table cell text.
class CellText extends StatelessWidget {
  final String text;
  final bool bold;
  final Color? color;

  const CellText(this.text, {super.key, this.bold = false, this.color});

  @override
  Widget build(BuildContext context) => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: (bold ? poppinsMedium : poppinsRegular).copyWith(
            fontSize: Constants.fontSizeDefault,
            color: color ?? context.textPrimary),
      );
}

/// "Showing 8 of 24" + Load more button under a paged table.
class LoadMoreBar extends StatelessWidget {
  final int shown;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  const LoadMoreBar({
    super.key,
    required this.shown,
    required this.total,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Constants.paddingSizeDefault),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'showing_of'.trParams({'shown': '$shown', 'total': '$total'}),
            style: poppinsRegular.copyWith(color: context.textSecondary),
          ),
          if (hasMore)
            OutlinedButton(
              onPressed: isLoadingMore ? null : onLoadMore,
              child: isLoadingMore
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('load_more'.tr),
            ),
        ],
      ),
    );
  }
}
