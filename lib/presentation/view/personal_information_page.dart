import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/theme/app_colors.dart';
import 'package:mobile_hexy/presentation/viewmodel/personal_information_view_model.dart';
import 'package:mobile_hexy/presentation/widgets/clean_app_bar.dart';
import 'package:mobile_hexy/presentation/widgets/shimmer_skeletons.dart';

class PersonalInformationPage extends GetView<PersonalInformationViewModel> {
  const PersonalInformationPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: const CleanAppBar(title: 'Personal Information'),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const _PersonalInformationShimmer();
      }
      final error = controller.loadError.value;
      if (error != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: controller.load,
                icon: const Icon(Icons.refresh_rounded),
                label: Text('Retry'.tr),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: InkWell(
                onTap: controller.isAvatarUploading.value
                    ? null
                    : controller.changePhoto,
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ClipOval(
                          child: _PersonalAvatar(
                            url: controller.avatarUrl.value,
                            bytes: controller.avatarBytes.value,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: AppColors.primary,
                            child: controller.isAvatarUploading.value
                                ? const Padding(
                                    padding: EdgeInsets.all(7),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Change Photo'.tr,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            _Field('First Name*', controller.firstName),
            _Field('Last Name*', controller.lastName),
            _Field(
              'Display Name',
              controller.displayName,
              helper: 'This is how your name appears publicly',
            ),
            _Field(
              'Phone Number*',
              controller.phone,
              prefix: Text('🇲🇲  +95  │  '.tr),
            ),
            _Field(
              'Email Address',
              controller.email,
              prefix: const Icon(Icons.mail_outline_rounded, size: 20),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: controller.isSaving.value ? null : controller.save,
                icon: controller.isSaving.value
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  controller.isSaving.value ? 'Saving...'.tr : 'Save'.tr,
                ),
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => Get.defaultDialog(
                title: 'Delete Account?',
                middleText: 'This action cannot be undone.',
                textCancel: 'Cancel',
                textConfirm: 'Delete',
                confirmTextColor: Colors.white,
              ),
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFFFEBEE),
                      child: Icon(
                        Icons.delete_outline,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Delete Account'.tr,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }),
  );
}

class _PersonalInformationShimmer extends StatelessWidget {
  const _PersonalInformationShimmer();

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: const [
        Center(child: ShimmerBox(width: 104, height: 104, radius: 52)),
        SizedBox(height: 28),
        ShimmerBox(width: double.infinity, height: 62, radius: 12),
        SizedBox(height: 14),
        ShimmerBox(width: double.infinity, height: 62, radius: 12),
        SizedBox(height: 14),
        ShimmerBox(width: double.infinity, height: 62, radius: 12),
        SizedBox(height: 14),
        ShimmerBox(width: double.infinity, height: 62, radius: 12),
        SizedBox(height: 22),
        ShimmerBox(width: double.infinity, height: 52, radius: 14),
      ],
    ),
  );
}

class _PersonalAvatar extends StatelessWidget {
  const _PersonalAvatar({required this.url, required this.bytes});

  final String url;
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 96,
    height: 96,
    child: bytes != null
        ? Image.memory(bytes!, fit: BoxFit.cover)
        : url.isEmpty
        ? Image.asset('assets/images/profile/avatar.png', fit: BoxFit.cover)
        : Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Image.asset(
              'assets/images/profile/avatar.png',
              fit: BoxFit.cover,
            ),
          ),
  );
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.controller, {this.helper, this.prefix});
  final String label;
  final TextEditingController controller;
  final String? helper;
  final Widget? prefix;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            prefixIcon: prefix,
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
        ),
        if (helper != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              helper!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
      ],
    ),
  );
}
