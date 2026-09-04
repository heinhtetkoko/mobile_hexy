import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/theme/app_colors.dart';
import 'package:mobile_hexy/presentation/viewmodel/address_form_view_model.dart';
import 'package:mobile_hexy/presentation/widgets/clean_app_bar.dart';

class AddressFormPage extends GetView<AddressFormViewModel> {
  const AddressFormPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: CleanAppBar(
      title: controller.isEditing ? 'Edit Address' : 'New Address',
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _TextField(
                  label: 'Address Name*',
                  controller: controller.nameController,
                ),
                const SizedBox(height: 16),
                _TextField(
                  label: 'Phone Number*',
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                Text(
                  'Address Type'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Wrap(
                    spacing: 12,
                    children:
                        const [
                          ('Home', '🏠'),
                          ('Office', '🏢'),
                          ('Other', '📍'),
                        ].map((option) {
                          final selected =
                              controller.addressType.value == option.$1;
                          return ChoiceChip(
                            key: Key('address-type-${option.$1.toLowerCase()}'),
                            selected: selected,
                            onSelected: (_) =>
                                controller.addressType.value = option.$1,
                            showCheckmark: false,
                            avatar: Text(
                              option.$2,
                              style: TextStyle(fontSize: 14),
                            ),
                            label: Text(option.$1.tr),
                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                            selectedColor: AppColors.primary,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                            side: BorderSide(
                              color: selected
                                  ? AppColors.primary
                                  : Theme.of(context).dividerColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => _DropdownField(
                    label: 'State / Region*',
                    value: controller.region.value,
                    items: {
                      ...controller.states.map((item) => item.name),
                      if (controller.region.value != null)
                        controller.region.value!,
                    }.toList(),
                    onChanged: controller.selectRegion,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => _DropdownField(
                    label: 'City / Township*',
                    value: controller.township.value,
                    hint: 'Select township',
                    items: {
                      ...controller.cities.map((item) => item.name),
                      if (controller.township.value != null)
                        controller.township.value!,
                    }.toList(),
                    onChanged: (value) => controller.township.value = value,
                  ),
                ),
                const SizedBox(height: 16),
                _TextField(
                  label: 'Street Address*',
                  controller: controller.streetController,
                  minLines: 3,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _TextField(
                  label: 'Building / Apt (Optional)',
                  controller: controller.buildingController,
                ),
                const SizedBox(height: 24),
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Set as Default Address'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Obx(
                        () => Switch(
                          key: const Key('default-address-toggle'),
                          value: controller.isDefault.value,
                          onChanged: (value) =>
                              controller.isDefault.value = value,
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 6,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: Obx(
                () => FilledButton.icon(
                  key: const Key('save-address'),
                  onPressed: controller.isSaving.value ? null : controller.save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  iconAlignment: IconAlignment.end,
                  icon: controller.isSaving.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(
                    controller.isSaving.value
                        ? 'Saving...'
                        : controller.isEditing
                        ? 'Update Address'
                        : 'Save Address',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });
  final String label;
  final String? value;
  final String? hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.tr,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        initialValue: value,
        hint: Text(
          hint ?? '',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item.tr,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 20,
        ),
        decoration: _inputDecoration(context),
      ),
    ],
  );
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.controller,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
  });
  final String label;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.tr,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
        ),
        decoration: _inputDecoration(context),
      ),
    ],
  );
}

InputDecoration _inputDecoration(BuildContext context) => InputDecoration(
  filled: true,
  fillColor: Theme.of(context).colorScheme.surface,
  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: Theme.of(context).dividerColor),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: Theme.of(context).dividerColor),
  ),
);
