import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CleanAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CleanAppBar({super.key, required this.title, this.showBack = true});

  final String title;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(57);

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: 56,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Theme.of(context).colorScheme.surface,
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
    automaticallyImplyLeading: false,
    leadingWidth: 70,
    leading: showBack
        ? IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
          )
        : const SizedBox.shrink(),
    title: Text(
      title.tr,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    ),
    actions: const [SizedBox(width: 70)],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Divider(height: 1, color: Theme.of(context).dividerColor),
    ),
  );
}
