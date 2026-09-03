import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/theme/app_colors.dart';
import 'package:mobile_hexy/presentation/viewmodel/change_password_view_model.dart';
import 'package:mobile_hexy/presentation/widgets/clean_app_bar.dart';

class ChangePasswordPage extends GetView<ChangePasswordViewModel> {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: const CleanAppBar(title: 'Change Password'),
    body: Obx(() {
      controller.revision.value;
      final strength = controller.strength;
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _PasswordField(
            label: 'Current Password',
            controller: controller.current,
            hidden: controller.currentHidden.value,
            icon: Icons.lock_outline,
            onEye: controller.currentHidden.toggle,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Forgot password?'.tr,
                style: TextStyle(color: AppColors.accent, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _PasswordField(
            label: 'New Password',
            controller: controller.password,
            hidden: controller.passwordHidden.value,
            icon: Icons.shield_outlined,
            onEye: controller.passwordHidden.toggle,
            onChanged: controller.updateRequirements,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < 4; i++)
                Expanded(
                  child: Container(
                    height: 6,
                    margin: EdgeInsets.only(right: i == 3 ? 0 : 8),
                    decoration: BoxDecoration(
                      color: i < strength
                          ? AppColors.success
                          : Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              Text(
                strength >= 3 ? 'Strong' : 'Weak',
                style: TextStyle(
                  color: strength >= 3
                      ? AppColors.success
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Req('At least 8 characters', controller.hasLength),
          _Req('Uppercase letter', controller.hasUppercase),
          _Req('Number', controller.hasNumber),
          _Req('Special character', controller.hasSpecial),
          const SizedBox(height: 18),
          _PasswordField(
            label: 'Confirm Password',
            controller: controller.confirm,
            hidden: controller.confirmHidden.value,
            icon: Icons.check_circle_outline,
            onEye: controller.confirmHidden.toggle,
            onChanged: controller.updateRequirements,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                controller.matches ? Icons.check_circle : Icons.circle_outlined,
                color: controller.matches
                    ? AppColors.success
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                controller.matches ? 'Passwords match' : 'Passwords must match',
                style: TextStyle(
                  color: controller.matches
                      ? AppColors.success
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
        ],
      );
    }),
  );
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.hidden,
    required this.icon,
    required this.onEye,
    this.onChanged,
  });
  final String label;
  final TextEditingController controller;
  final bool hidden;
  final IconData icon;
  final VoidCallback onEye;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$label  *'.tr,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        obscureText: hidden,
        onChanged: onChanged,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          suffixIcon: IconButton(
            onPressed: onEye,
            icon: Icon(
              hidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
      ),
    ],
  );
}

class _Req extends StatelessWidget {
  const _Req(this.label, this.met);
  final String label;
  final bool met;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(
          met ? Icons.check : Icons.close,
          color: met
              ? AppColors.success
              : Theme.of(context).colorScheme.onSurfaceVariant,
          size: 15,
        ),
        const SizedBox(width: 6),
        Text(
          label.tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
