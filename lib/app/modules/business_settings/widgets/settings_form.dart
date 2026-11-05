import 'package:appwrite_boilerplate/app/common/widgets/admin_card.dart';
import 'package:appwrite_boilerplate/app/common/widgets/admin_dialogs.dart';
import 'package:appwrite_boilerplate/app/common/widgets/custom_toster.dart';
import 'package:appwrite_boilerplate/app/controllers/business_settings_controller.dart';
import 'package:appwrite_boilerplate/app/helper/admin_format.dart';
import 'package:appwrite_boilerplate/app/models/booking_model.dart';
import 'package:appwrite_boilerplate/app/models/business_settings_model.dart';
import 'package:appwrite_boilerplate/app/modules/business_settings/widgets/settings_number_field.dart';
import 'package:appwrite_boilerplate/app/resources/colors.dart';
import 'package:appwrite_boilerplate/app/resources/constants.dart';
import 'package:appwrite_boilerplate/app/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Editable form bound to the controller's draft. Text controllers live here
/// (seeded once from the loaded settings, reset on discard).
class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final BusinessSettingsController _c = Get.find<BusinessSettingsController>();
  late final Map<String, TextEditingController> _t;

  Map<String, String> _values(BusinessSettingsModel s) => {
        'businessName': s.businessName,
        'supportPhone': s.supportPhone,
        'supportEmail': s.supportEmail,
        'defaultSearchRadiusKm': '${s.defaultSearchRadiusKm}',
        'maxSearchRadiusKm': '${s.maxSearchRadiusKm}',
        'bookingExpirySeconds': '${s.bookingExpirySeconds}',
        'driverLocationFreshnessSeconds': '${s.driverLocationFreshnessSeconds}',
      };

  @override
  void initState() {
    super.initState();
    _t = {
      for (final e in _values(_c.draft!).entries)
        e.key: TextEditingController(text: e.value),
    };
  }

  @override
  void dispose() {
    for (final t in _t.values) {
      t.dispose();
    }
    super.dispose();
  }

  void _discard() {
    _c.discard();
    _values(_c.draft!).forEach((k, v) => _t[k]!.text = v);
  }

  Future<void> _save() async {
    final ok = await showConfirmDialog(context,
        title: 'save_settings_title'.tr,
        message: 'save_settings_desc'.tr,
        confirmLabel: 'save'.tr);
    if (!ok) return;
    final error = await _c.save();
    customToster(error ?? 'settings_saved_toast'.tr, isSuccess: error == null);
  }

  Widget _text(String key, String label, String helper, String? error,
      {TextInputType? type, required BusinessSettingsModel Function(BusinessSettingsModel d, String v) apply}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Constants.paddingSizeDefault),
      child: TextField(
        controller: _t[key],
        keyboardType: type,
        onChanged: (v) => _c.edit((d) => apply(d, v)),
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          errorText: error?.tr,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Constants.radiusDefault)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessSettingsController>(builder: (c) {
      final d = c.draft!;
      final e = c.errors;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (c.hasUnsavedChanges)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Constants.paddingSizeSmall,
                      vertical: Constants.chipVerticalPadding),
                  decoration: BoxDecoration(
                    color: ColorResource.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Constants.radiusExtraLarge),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.circle, size: 8, color: ColorResource.accentDark),
                    const SizedBox(width: Constants.paddingSizeExtraSmall),
                    Text('unsaved_changes'.tr,
                        style: poppinsMedium.copyWith(
                            fontSize: Constants.fontSizeSmall,
                            color: ColorResource.accentDark)),
                  ]),
                ),
              const Spacer(),
              TextButton(
                  onPressed: c.hasUnsavedChanges && !c.isSaving ? _discard : null,
                  child: Text('discard'.tr)),
              const SizedBox(width: Constants.paddingSizeSmall),
              FilledButton(
                onPressed: c.hasUnsavedChanges && c.isValid && !c.isSaving ? _save : null,
                child: c.isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('save'.tr),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingSizeDefault),
          AdminCard(
            title: 'business_info'.tr,
            child: Column(children: [
              _text('businessName', 'business_name'.tr, 'helper_business_name'.tr, e['businessName'],
                  apply: (d, v) => d.copyWith(businessName: v)),
              _text('supportPhone', 'support_phone'.tr, 'helper_support_phone'.tr, e['supportPhone'],
                  type: TextInputType.phone, apply: (d, v) => d.copyWith(supportPhone: v)),
              _text('supportEmail', 'support_email'.tr, 'helper_support_email'.tr, e['supportEmail'],
                  type: TextInputType.emailAddress, apply: (d, v) => d.copyWith(supportEmail: v)),
              Padding(
                padding: const EdgeInsets.only(bottom: Constants.paddingSizeDefault),
                child: TextFormField(
                  initialValue: BusinessSettingsModel.currency,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'currency'.tr,
                    helperText: 'helper_currency'.tr,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Constants.radiusDefault)),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: Constants.paddingSizeLarge),
          AdminCard(
            title: 'enabled_vehicle_types'.tr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final v in VehicleType.values)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(vehicleLabel(v)),
                    value: d.enabledVehicleTypes.contains(v),
                    onChanged: (on) => c.toggleVehicle(v, on),
                  ),
                Text(
                  (e['enabledVehicleTypes'] ?? 'helper_vehicle_types').tr,
                  style: poppinsRegular.copyWith(
                      fontSize: Constants.fontSizeSmall,
                      color: e['enabledVehicleTypes'] != null
                          ? ColorResource.error
                          : context.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: Constants.paddingSizeLarge),
          AdminCard(
            title: 'booking_rules'.tr,
            child: Column(children: [
              SettingsNumberField(
                controller: _t['defaultSearchRadiusKm']!,
                label: 'default_search_radius_km'.tr,
                helper: 'helper_default_radius'.tr,
                errorKey: e['defaultSearchRadiusKm'],
                min: BusinessSettingsModel.minRadiusKm,
                max: BusinessSettingsModel.maxRadiusKm,
                onChanged: (v) => c.edit((d) => d.copyWith(defaultSearchRadiusKm: v)),
              ),
              SettingsNumberField(
                controller: _t['maxSearchRadiusKm']!,
                label: 'max_search_radius_km'.tr,
                helper: 'helper_max_radius'.tr,
                errorKey: e['maxSearchRadiusKm'],
                min: BusinessSettingsModel.minRadiusKm,
                max: BusinessSettingsModel.maxRadiusKm,
                onChanged: (v) => c.edit((d) => d.copyWith(maxSearchRadiusKm: v)),
              ),
              SettingsNumberField(
                controller: _t['bookingExpirySeconds']!,
                label: 'booking_expiry_seconds'.tr,
                helper: 'helper_booking_expiry'.tr,
                errorKey: e['bookingExpirySeconds'],
                min: BusinessSettingsModel.minExpirySeconds,
                max: BusinessSettingsModel.maxExpirySeconds,
                onChanged: (v) => c.edit((d) => d.copyWith(bookingExpirySeconds: v)),
              ),
              SettingsNumberField(
                controller: _t['driverLocationFreshnessSeconds']!,
                label: 'driver_location_freshness_seconds'.tr,
                helper: 'helper_location_freshness'.tr,
                errorKey: e['driverLocationFreshnessSeconds'],
                min: BusinessSettingsModel.minFreshnessSeconds,
                max: BusinessSettingsModel.maxFreshnessSeconds,
                onChanged: (v) =>
                    c.edit((d) => d.copyWith(driverLocationFreshnessSeconds: v)),
              ),
            ]),
          ),
        ],
      );
    });
  }
}
