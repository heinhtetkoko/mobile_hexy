import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/request_state.dart';
import 'package:mobile_hexy/data/models/shipping_address.dart';
import 'package:mobile_hexy/presentation/viewmodel/shipping_addresses_view_model.dart';
import 'package:mobile_hexy/presentation/widgets/clean_app_bar.dart';
import 'package:mobile_hexy/presentation/widgets/shimmer_skeletons.dart';

class ShippingAddressesPage extends GetView<ShippingAddressesViewModel> {
  const ShippingAddressesPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CleanAppBar(title: 'Shipping Addresses'),
    floatingActionButton: FloatingActionButton(
      key: const Key('new-shipping-address'),
      onPressed: controller.addNew,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      shape: const CircleBorder(),
      child: const Icon(Icons.add_rounded, size: 30),
    ),
    body: Obx(() {
      if (controller.requestState.value == RequestState.loading &&
          controller.addresses.isEmpty) {
        return const _AddressesShimmer();
      }
      if (controller.requestState.value == RequestState.error &&
          controller.addresses.isEmpty) {
        return _MessageState(
          icon: Icons.cloud_off_outlined,
          title: 'Could not load addresses',
          message: controller.errorMessage.value ?? 'Please try again.',
          buttonText: 'Try Again',
          onPressed: controller.loadAddresses,
        );
      }
      if (controller.addresses.isEmpty) {
        return _MessageState(
          icon: Icons.location_on_outlined,
          title: 'No shipping addresses',
          message: 'Add an address for faster checkout and delivery.',
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadAddresses,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          itemCount: controller.addresses.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final address = controller.addresses[index];
            return _AddressCard(
              address: address,
              deleting: controller.deletingId.value == address.id,
              onEdit: () => controller.edit(address),
              onDelete: () => controller.confirmDelete(address),
            );
          },
        ),
      );
    }),
  );
}

class _AddressesShimmer extends StatelessWidget {
  const _AddressesShimmer();

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) =>
          const ShimmerBox(width: double.infinity, height: 150, radius: 16),
    ),
  );
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.deleting,
    required this.onEdit,
    required this.onDelete,
  });
  final ShippingAddress address;
  final bool deleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).dividerColor),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black.withValues(alpha: .4)
              : const Color(0x0A000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            address.addressType == 'office'
                ? Icons.business_outlined
                : Icons.home_outlined,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      address.name.isEmpty
                          ? address.addressType.capitalizeFirst ?? 'Address'
                          : address.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (address.isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Default',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (address.phone.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  address.phone,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 5),
              Text(
                [
                  address.building,
                  address.streetAddress,
                  address.cityTownship,
                  address.stateRegion,
                ].where((value) => value.isNotEmpty).join(', '),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 17),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: deleting ? null : onDelete,
                    icon: deleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline_rounded, size: 17),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onPressed,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 58,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (buttonText != null && onPressed != null) ...[
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(buttonText!),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
