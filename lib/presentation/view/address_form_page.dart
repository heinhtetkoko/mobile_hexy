import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app/theme/app_colors.dart';
import 'package:mobile_hexy/presentation/viewmodel/address_form_view_model.dart';

class AddressFormPage extends GetView<AddressFormViewModel> {
  const AddressFormPage({super.key});

  static const _border = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          _Header(isEditing: controller.isEditing),
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              children: [
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
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            side: BorderSide(
                              color: selected ? AppColors.primary : _border,
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
                    items: AddressFormViewModel.regions,
                    onChanged: (value) => controller.region.value = value!,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => _DropdownField(
                    label: 'City / Township*',
                    value: controller.township.value,
                    hint: 'Select township',
                    items: AddressFormViewModel.townships,
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
                    border: Border.all(color: _border),
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
                        color: AppColors.primary,
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
              child: FilledButton.icon(
                key: const Key('save-address'),
                onPressed: controller.save,
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
                icon: Icon(Icons.check_rounded, size: 18),
                label: Text(
                  controller.isEditing ? 'Update Address' : 'Save Address',
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.isEditing});
  final bool isEditing;

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 6,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        SizedBox(
          width: 70,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: AppColors.surface,
              shape: const CircleBorder(),
              child: IconButton(
                key: const Key('address-back'),
                onPressed: Get.back,
                icon: Icon(Icons.arrow_back_rounded, size: 18),
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            isEditing ? 'Edit Address' : 'New Address',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 70),
      ],
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
          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item.tr)))
            .toList(),
        onChanged: onChanged,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF9CA3AF),
          size: 20,
        ),
        decoration: _inputDecoration(),
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
  });
  final String label;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;

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
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
        ),
        decoration: _inputDecoration(),
      ),
    ],
  );
}

InputDecoration _inputDecoration() => InputDecoration(
  filled: true,
  fillColor: AppColors.surface,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AddressFormPage._border),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AddressFormPage._border),
  ),
);
