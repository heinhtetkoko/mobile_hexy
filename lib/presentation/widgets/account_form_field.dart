import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shared field styling for account password and recovery screens.
class AccountFormField extends StatelessWidget {
  const AccountFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.obscureText = false,
    this.onToggleVisibility,
    this.onChanged,
    this.keyboardType,
    this.onSubmitted,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

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
        obscureText: obscureText,
        onChanged: onChanged,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        enabled: enabled,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          suffixIcon: onToggleVisibility == null
              ? null
              : IconButton(
                  onPressed: onToggleVisibility,
                  icon: Icon(
                    obscureText
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
