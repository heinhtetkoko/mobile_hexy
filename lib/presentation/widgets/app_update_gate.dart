import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/services/app_update_service.dart';
import 'package:mobile_hexy/presentation/view/app_update_page.dart';

/// A mandatory update covers every route, so route changes cannot bypass it.
class AppUpdateGate extends StatelessWidget {
  const AppUpdateGate({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final updates = Get.find<AppUpdateService>();
    return Obx(() {
      final required = updates.requiredUpdate.value;
      return Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(
            excluding: required != null,
            child: IgnorePointer(ignoring: required != null, child: child),
          ),
          if (required != null)
            Positioned.fill(
              child: AppUpdatePage(
                key: ValueKey(required.policy.version),
                update: required,
              ),
            ),
        ],
      );
    });
  }
}
