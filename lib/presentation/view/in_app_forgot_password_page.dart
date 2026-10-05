import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/viewmodel/in_app_forgot_password_view_model.dart';
import 'package:mobile_hexy/presentation/widgets/account_form_field.dart';
import 'package:mobile_hexy/presentation/widgets/clean_app_bar.dart';

class InAppForgotPasswordPage extends GetView<InAppForgotPasswordViewModel> {
  const InAppForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) => Obx(
    () => PopScope(
      canPop: !controller.isSubmitting.value,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CleanAppBar(
          title: 'Forgot Password',
          showBack: !controller.isSubmitting.value,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AccountFormField(
              label: 'Email',
              controller: controller.email,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              enabled: !controller.isSubmitting.value,
              onSubmitted: (_) => controller.submit(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: controller.isSubmitting.value
                    ? null
                    : controller.submit,
                icon: controller.isSubmitting.value
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.mail_outline),
                label: Text(
                  controller.isSubmitting.value
                      ? 'Sending...'.tr
                      : 'Send reset email'.tr,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
