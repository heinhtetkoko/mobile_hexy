import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app/theme/app_colors.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});
  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  late final fields = [
    TextEditingController(text: 'Zar'),
    TextEditingController(text: 'Zar'),
    TextEditingController(text: 'Zar Zar'),
    TextEditingController(text: '09-123-456-789'),
    TextEditingController(text: 'sarah.johnson@email.com'),
  ];
  @override
  void dispose() {
    for (final field in fields) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: const _ChildBar(title: 'Personal Information'),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/profile/avatar.png',
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.primary,
                      child: Icon(
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
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _Field('First Name*', fields[0]),
        _Field('Last Name*', fields[1]),
        _Field(
          'Display Name',
          fields[2],
          helper: 'This is how your name appears publicly',
        ),
        _Field('Phone Number*', fields[3], prefix: Text('🇲🇲  +95  │  '.tr)),
        _Field(
          'Email Address',
          fields[4],
          prefix: const Icon(
            Icons.mail_outline_rounded,
            color: Color(0xFF9CA3AF),
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: () => Get.snackbar(
              'Profile saved',
              'Your personal information has been updated.',
              snackPosition: SnackPosition.BOTTOM,
            ),
            icon: const Icon(Icons.check),
            label: Text('Save'.tr),
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
                CircleAvatar(
                  backgroundColor: Color(0xFFFFEBEE),
                  child: Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                ),
                SizedBox(width: 12),
                Text(
                  'Delete Account'.tr,
                  style: TextStyle(
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
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: prefix,
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),
        if (helper != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              helper!,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
            ),
          ),
      ],
    ),
  );
}

class _ChildBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChildBar({required this.title});
  final String title;
  @override
  Size get preferredSize => const Size.fromHeight(56);
  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    centerTitle: true,
    leading: Padding(
      padding: const EdgeInsets.all(10),
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.chevron_left),
        ),
      ),
    ),
    title: Text(
      title.tr,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    ),
  );
}
