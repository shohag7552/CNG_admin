import 'package:appwrite_boilerplate/app/models/admin_stats_model.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Bookings per day as plain-widget bars (no chart package).
class BookingsBarChart extends StatelessWidget {
  final List<DailyBookingsModel> days;

  const BookingsBarChart({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final max = days.fold<int>(1, (m, d) => d.total > m ? d.total : m);
    const labelHeight = Constants.paddingSizeExtraLarge;
    return SizedBox(
      height: Constants.chartHeight + labelHeight * 2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in days)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Constants.paddingSizeExtraSmall),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${d.total}',
                        style: poppinsMedium.copyWith(
                            fontSize: Constants.fontSizeSmall,
                            color: context.textPrimary)),
                    const SizedBox(height: Constants.paddingSizeExtraSmall),
                    Container(
                      height: Constants.chartHeight * d.total / max,
                      decoration: BoxDecoration(
                        color: ColorResource.primaryDark,
                        borderRadius:
                            BorderRadius.circular(Constants.radiusSmall),
                      ),
                    ),
                    const SizedBox(height: Constants.paddingSizeExtraSmall),
                    Text(DateFormat.E().format(d.day),
                        style: poppinsRegular.copyWith(
                            fontSize: Constants.fontSizeSmall,
                            color: context.textSecondary)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
