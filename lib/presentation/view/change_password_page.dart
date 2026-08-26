import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app/theme/app_colors.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final current = TextEditingController(),
      password = TextEditingController(),
      confirm = TextEditingController();
  final hidden = [true, true, true];
  bool get length => password.text.length >= 8;
  bool get upper => password.text.contains(RegExp('[A-Z]'));
  bool get number => password.text.contains(RegExp('[0-9]'));
  bool get special => password.text.contains(RegExp(r'[^A-Za-z0-9]'));
  bool get matches => password.text.isNotEmpty && password.text == confirm.text;
  @override
  void dispose() {
    current.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  void save() {
    if (current.text.isEmpty || !length || !upper || !number || !matches) {
      Get.snackbar(
        'Check your password',
        'Complete the requirements and make sure passwords match.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.snackbar(
      'Password changed',
      'Your password has been saved.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strength = [length, upper, number, special].where((v) => v).length;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const _ChildBar2(),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _PasswordField(
            label: 'Current Password',
            controller: current,
            hidden: hidden[0],
            icon: Icons.lock_outline,
            onEye: () => setState(() => hidden[0] = !hidden[0]),
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
            controller: password,
            hidden: hidden[1],
            icon: Icons.shield_outlined,
            onEye: () => setState(() => hidden[1] = !hidden[1]),
            onChanged: (_) => setState(() {}),
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
                          : const Color(0xFFE5E7EB),
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
                      : const Color(0xFF9CA3AF),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Req('At least 8 characters', length),
          _Req('Uppercase letter', upper),
          _Req('Number', number),
          _Req('Special character', special),
          const SizedBox(height: 18),
          _PasswordField(
            label: 'Confirm Password',
            controller: confirm,
            hidden: hidden[2],
            icon: Icons.check_circle_outline,
            onEye: () => setState(() => hidden[2] = !hidden[2]),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                matches ? Icons.check_circle : Icons.circle_outlined,
                color: matches ? AppColors.success : const Color(0xFF9CA3AF),
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                matches ? 'Passwords match' : 'Passwords must match',
                style: TextStyle(
                  color: matches ? AppColors.success : const Color(0xFF9CA3AF),
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
              onPressed: save,
              icon: const Icon(Icons.check),
              label: Text('Save'.tr),
            ),
          ),
        ],
      ),
    );
  }
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
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        obscureText: hidden,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
          suffixIcon: IconButton(
            onPressed: onEye,
            icon: Icon(
              hidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
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
          color: met ? AppColors.success : const Color(0xFF9CA3AF),
          size: 15,
        ),
        const SizedBox(width: 6),
        Text(
          label.tr,
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
        ),
      ],
    ),
  );
}

class _ChildBar2 extends StatelessWidget implements PreferredSizeWidget {
  const _ChildBar2();
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
      'Change Password'.tr,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    ),
  );
}
