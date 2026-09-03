import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/presentation/viewmodel/auth_view_model.dart';

const _authNavy = Color(0xFF1E1B4B);
const _authPink = Color(0xFFDB2777);

class LoginPage extends GetView<AuthViewModel> {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) => _AuthScaffold(
    child: _AuthCard(
      height: 590,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AuthTitle('Login Now'),
          const SizedBox(height: 22),
          _AuthField(
            controller: controller.email,
            hint: 'Email or Username',
            icon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: 12),
          Obx(
            () => _AuthField(
              controller: controller.password,
              hint: 'Password',
              icon: Icons.lock_outline_rounded,
              obscureText: controller.passwordHidden.value,
              onVisibility: controller.togglePassword,
            ),
          ),
          Row(
            children: [
              Obx(
                () => Checkbox(
                  value: controller.rememberLogin.value,
                  onChanged: controller.setRememberLogin,
                  activeColor: _authPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const Expanded(
                child: Text(
                  'Remember me',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ),
              _LinkRow(
                label: 'Forgot Password?',
                onTap: () => Get.toNamed<void>(AppRoutes.forgotPassword),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(
            () => _PrimaryButton(
              label: 'Login',
              onPressed: controller.login,
              loading: controller.isLoggingIn.value,
            ),
          ),
          const SizedBox(height: 24),
          const _DividerLabel('Or login with'),
          const SizedBox(height: 24),
          Obx(
            () => _SocialButton(
              onPressed: controller.loginWithGoogle,
              loading: controller.isGoogleLoggingIn.value,
            ),
          ),
          const SizedBox(height: 24),
          _BottomLink(
            prefix: "Don't have an account?",
            label: 'Sign Up',
            onTap: () => Get.toNamed<void>(AppRoutes.register),
          ),
        ],
      ),
    ),
  );
}

class RegisterPage extends GetView<AuthViewModel> {
  const RegisterPage({super.key});
  @override
  Widget build(BuildContext context) => _AuthScaffold(
    child: _AuthCard(
      height: 590,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AuthTitle('SignUp Now'),
          const SizedBox(height: 22),
          _AuthField(
            controller: controller.username,
            hint: 'Username',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 12),
          _AuthField(
            controller: controller.email,
            hint: 'Email',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          Obx(
            () => _AuthField(
              controller: controller.password,
              hint: 'Password',
              icon: Icons.lock_outline_rounded,
              obscureText: controller.passwordHidden.value,
              onVisibility: controller.togglePassword,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => _AuthField(
              controller: controller.confirmPassword,
              hint: 'Confirm Password',
              icon: Icons.lock_outline_rounded,
              obscureText: controller.confirmPasswordHidden.value,
              onVisibility: controller.toggleConfirmPassword,
            ),
          ),
          const SizedBox(height: 18),
          Obx(
            () => _PrimaryButton(
              label: 'Sign Up',
              onPressed: controller.register,
              loading: controller.isRegistering.value,
            ),
          ),
          const SizedBox(height: 24),
          const _DividerLabel('Or login with'),
          const SizedBox(height: 24),
          Obx(
            () => _SocialButton(
              onPressed: controller.loginWithGoogle,
              loading: controller.isGoogleLoggingIn.value,
            ),
          ),
          const SizedBox(height: 24),
          _BottomLink(
            prefix: 'Already have an account?',
            label: 'Sign In',
            onTap: Get.back,
          ),
        ],
      ),
    ),
  );
}

class ForgotPasswordPage extends GetView<AuthViewModel> {
  const ForgotPasswordPage({super.key});
  @override
  Widget build(BuildContext context) => _AuthScaffold(
    child: _AuthCard(
      child: Column(
        children: [
          const _BackButton(),
          const _AuthIllustration(
            icon: Icons.lock_outline_rounded,
            badge: Icons.mail_outline_rounded,
            tall: true,
          ),
          const _CenteredHeading(
            title: 'Forgot Password?',
            subtitle:
                "Enter your registered email address and we'll send you a verification code.",
          ),
          const SizedBox(height: 24),
          _AuthField(
            controller: controller.email,
            hint: 'Enter your email address',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            tall: true,
          ),
          const SizedBox(height: 24),
          _PrimaryButton(
            label: 'Send Verification Code',
            onPressed: controller.sendCode,
            tall: true,
          ),
          const SizedBox(height: 24),
          _BottomLink(
            prefix: 'Remember your password?',
            label: 'Sign In',
            onTap: () => Get.offNamed<void>(AppRoutes.login),
          ),
        ],
      ),
    ),
  );
}

class OtpVerificationPage extends GetView<AuthViewModel> {
  const OtpVerificationPage({super.key});
  @override
  Widget build(BuildContext context) {
    final email = Get.arguments is String
        ? Get.arguments as String
        : 'hello@hexcy.com';
    return _AuthScaffold(
      child: _AuthCard(
        child: Column(
          children: [
            const _BackButton(),
            const _AuthIllustration(
              icon: Icons.mark_email_read_outlined,
              badge: Icons.verified_user_outlined,
            ),
            _CenteredHeading(
              title: 'Verify Your Email',
              subtitle: "We've sent a 6-digit code to\n$email",
              emphasized: email,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 44,
                  height: 56,
                  child: TextField(
                    key: Key('otp-$index'),
                    controller: controller.otp[index],
                    focusNode: controller.otpFocus[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    onChanged: (value) => controller.onOtpChanged(index, value),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _PrimaryButton(
              label: 'Verify Code',
              onPressed: controller.verifyCode,
              tall: true,
            ),
          ],
        ),
      ),
    );
  }
}

class ResetPasswordPage extends GetView<AuthViewModel> {
  const ResetPasswordPage({super.key});
  @override
  Widget build(BuildContext context) => _AuthScaffold(
    child: SingleChildScrollView(
      child: _AuthCard(
        child: Column(
          children: [
            const _BackButton(),
            const _AuthIllustration(
              icon: Icons.lock_outline_rounded,
              badge: Icons.key_rounded,
            ),
            const _CenteredHeading(
              title: 'Create New Password',
              subtitle:
                  'Your new password must be different from previously used passwords.',
            ),
            const SizedBox(height: 24),
            Obx(
              () => _AuthField(
                controller: controller.password,
                hint: 'New Password',
                icon: Icons.lock_outline_rounded,
                obscureText: controller.passwordHidden.value,
                onVisibility: controller.togglePassword,
                tall: true,
              ),
            ),
            const SizedBox(height: 7),
            const _PasswordStrength(),
            const SizedBox(height: 16),
            Obx(
              () => _AuthField(
                controller: controller.confirmPassword,
                hint: 'Confirm Password',
                icon: Icons.lock_outline_rounded,
                obscureText: controller.confirmPasswordHidden.value,
                onVisibility: controller.toggleConfirmPassword,
                tall: true,
              ),
            ),
            const SizedBox(height: 24),
            const _PasswordRules(),
            const SizedBox(height: 24),
            _PrimaryButton(
              label: 'Reset Password',
              onPressed: controller.resetPassword,
              tall: true,
            ),
          ],
        ),
      ),
    ),
  );
}

class PasswordUpdatedPage extends GetView<AuthViewModel> {
  const PasswordUpdatedPage({super.key});
  @override
  Widget build(BuildContext context) => _AuthScaffold(
    child: _AuthCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 70),
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x3322C55E),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 52,
            ),
          ),
          const SizedBox(height: 68),
          const _CenteredHeading(
            title: 'Password Updated!',
            subtitle:
                'Your password has been successfully updated. You can now sign in with your new password.',
          ),
          const SizedBox(height: 60),
          _PrimaryButton(
            label: 'Back to Login',
            onPressed: () => Get.offAllNamed<void>(AppRoutes.login),
            tall: true,
          ),
        ],
      ),
    ),
  );
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _authNavy,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: child,
        ),
      ),
    ),
  );
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child, this.height});
  final Widget child;
  final double? height;
  @override
  Widget build(BuildContext context) => Container(
    width: 342,
    height: height,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(
          color: Color(0x24000000),
          blurRadius: 20,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: child,
  );
}

class _AuthTitle extends StatelessWidget {
  const _AuthTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text.tr,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 28,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.onVisibility,
    this.tall = false,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final VoidCallback? onVisibility;
  final bool tall;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: tall ? 56 : 52,
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: hint.tr,
        prefixIcon: Icon(icon, size: 21),
        suffixIcon: onVisibility == null
            ? null
            : IconButton(
                onPressed: onVisibility,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 21,
                ),
              ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tall ? 16 : 12),
        ),
      ),
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.tall = false,
    this.loading = false,
  });
  final String label;
  final VoidCallback onPressed;
  final bool tall;
  final bool loading;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: tall ? 56 : 52,
    child: FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: _authNavy,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tall ? 16 : 12),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        elevation: tall ? 5 : 0,
      ),
      child: loading
          ? const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Text(label.tr),
    ),
  );
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: _authPink,
        padding: const EdgeInsets.only(top: 8),
      ),
      child: Text(
        label.tr,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Divider(color: Theme.of(context).dividerColor)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          label.tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Expanded(child: Divider(color: Theme.of(context).dividerColor)),
    ],
  );
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.onPressed, required this.loading});

  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: OutlinedButton.icon(
      onPressed: loading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        side: BorderSide(color: Theme.of(context).dividerColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: loading
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.g_mobiledata_rounded, size: 24),
      label: Text(
        'Login with Google'.tr,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}

class _BottomLink extends StatelessWidget {
  const _BottomLink({
    required this.prefix,
    required this.label,
    required this.onTap,
  });
  final String prefix;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        '${prefix.tr} ',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      ),
      GestureDetector(
        onTap: onTap,
        child: Text(
          label.tr,
          style: const TextStyle(
            color: _authPink,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

class _BackButton extends StatelessWidget {
  const _BackButton();
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: IconButton(
      onPressed: Get.back,
      icon: Icon(
        Icons.arrow_back_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
      padding: EdgeInsets.zero,
      alignment: Alignment.centerLeft,
    ),
  );
}

class _AuthIllustration extends StatelessWidget {
  const _AuthIllustration({
    required this.icon,
    required this.badge,
    this.tall = false,
  });
  final IconData icon;
  final IconData badge;
  final bool tall;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: tall ? 160 : 130,
    child: Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x22DB2777), Colors.transparent],
              ),
            ),
            child: Icon(icon, color: _authNavy, size: 62),
          ),
          Positioned(
            right: -7,
            bottom: 8,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _authPink,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(badge, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    ),
  );
}

class _CenteredHeading extends StatelessWidget {
  const _CenteredHeading({
    required this.title,
    required this.subtitle,
    this.emphasized,
  });
  final String title;
  final String subtitle;
  final String? emphasized;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        title.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        subtitle.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
          height: 1.5,
          fontWeight: emphasized == null ? FontWeight.w400 : FontWeight.w500,
        ),
      ),
    ],
  );
}

class _PasswordStrength extends StatelessWidget {
  const _PasswordStrength();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(child: Container(height: 4, color: _authPink)),
          const SizedBox(width: 4),
          Expanded(child: Container(height: 4, color: _authPink)),
          const SizedBox(width: 4),
          Expanded(
            child: Container(height: 4, color: Theme.of(context).dividerColor),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        'Medium'.tr,
        style: TextStyle(
          color: _authPink,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _PasswordRules extends StatelessWidget {
  const _PasswordRules();
  static const rules = [
    'At least 8 characters',
    'One uppercase letter',
    'One lowercase letter',
    'One number',
    'One special character',
  ];
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: .55),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: List.generate(
        rules.length,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index == rules.length - 1 ? 0 : 10),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 17,
                color: index < 2
                    ? const Color(0xFF22C55E)
                    : Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 8),
              Text(
                rules[index].tr,
                style: TextStyle(
                  color: index < 2
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
