import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app/theme/app_colors.dart';
import 'package:mobile_hexy/presentation/viewmodel/profile_view_model.dart';

class ProfilePage extends GetView<ProfileViewModel> {
  const ProfilePage({super.key});

  static const _divider = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _ProfileAppBar(onTap: controller.openItem)),
          const SliverToBoxAdapter(child: _ProfileHero()),
          SliverToBoxAdapter(child: _Orders(onTap: controller.openItem)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverList.list(
              children: [
                _MenuSection(
                  title: 'MY ACCOUNT',
                  items: const [
                    _MenuItem(
                      Icons.person_outline_rounded,
                      'Personal Information',
                    ),
                    _MenuItem(Icons.location_on_outlined, 'Shipping Addresses'),
                    _MenuItem(Icons.lock_outline_rounded, 'Change Password'),
                  ],
                  onTap: controller.openItem,
                ),
                _MenuSection(
                  title: 'SUPPORT',
                  items: const [
                    _MenuItem(
                      Icons.phone_outlined,
                      'Hot Line',
                      trailingText: '09-123-456-789',
                    ),
                    _MenuItem(Icons.contact_mail_outlined, 'Contact Us'),
                    _MenuItem(Icons.format_list_bulleted_rounded, 'FAQ'),
                  ],
                  onTap: controller.openItem,
                ),
                Obx(
                  () => _MenuSection(
                    title: 'APPLICATION',
                    items: [
                      _MenuItem(
                        Icons.language_rounded,
                        'Language',
                        trailingText: controller.currentLanguage.value,
                      ),
                      _MenuItem(
                        Icons.dark_mode_outlined,
                        'Dark Mode',
                        toggleValue: controller.darkModeEnabled.value,
                        onToggle: controller.toggleDarkMode,
                      ),
                      const _MenuItem(Icons.info_outline_rounded, 'About Us'),
                      const _MenuItem(Icons.shield_outlined, 'Privacy Policy'),
                      const _MenuItem(
                        Icons.description_outlined,
                        'Terms & Conditions',
                      ),
                    ],
                    onTap: controller.openItem,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    key: const Key('profile-log-out'),
                    onPressed: controller.logOut,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 1.2,
                      ),
                      shape: const StadiumBorder(),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: Icon(Icons.logout_rounded, size: 20),
                    label: Text('Log Out'.tr),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      Text(
                        'HEXY STATIONERY'.tr,
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Version 2.4.1'.tr,
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar({required this.onTap});
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: Color(0x0D1F2937),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        const SizedBox(width: 80),
        Expanded(
          child: Text(
            'My Profile'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Row(
          children: [
            _RoundAction(
              key: const Key('profile-notifications'),
              icon: Icons.notifications_none_rounded,
              onTap: () => onTap('Notifications'),
            ),
            const SizedBox(width: 8),
            _RoundAction(
              key: const Key('profile-settings'),
              icon: Icons.settings_outlined,
              onTap: () => onTap('Settings'),
            ),
          ],
        ),
      ],
    ),
  );
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({super.key, required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ),
  );
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero();

  @override
  Widget build(BuildContext context) => Container(
    height: 164,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.primary, Color(0xFF312E81)],
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile/avatar.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Zar Zar'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _Orders extends StatelessWidget {
  const _Orders({required this.onTap});
  final ValueChanged<String> onTap;

  static const _items = [
    _OrderItem(Icons.schedule_rounded, 'Pending', '2', Color(0xFFF59E0B)),
    _OrderItem(Icons.sync_rounded, 'Processing', '1', Color(0xFF3B82F6)),
    _OrderItem(
      Icons.currency_exchange_rounded,
      'Refunded',
      '0',
      Color(0xFFF59E0B),
    ),
    _OrderItem(
      Icons.check_circle_outline_rounded,
      'Delivered',
      '18',
      AppColors.success,
    ),
    _OrderItem(
      Icons.cancel_outlined,
      'Cancelled',
      null,
      AppColors.textSecondary,
    ),
  ];

  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).colorScheme.surface,
    padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
    child: Column(
      children: [
        Row(
          children: [
            Text(
              'My Orders'.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () => onTap('My Orders'),
              child: Text(
                'View All'.tr,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _items
              .map(
                (item) =>
                    _OrderStatus(item: item, onTap: () => onTap(item.label)),
              )
              .toList(),
        ),
      ],
    ),
  );
}

class _OrderItem {
  const _OrderItem(this.icon, this.label, this.count, this.badgeColor);
  final IconData icon;
  final String label;
  final String? count;
  final Color badgeColor;
}

class _OrderStatus extends StatelessWidget {
  const _OrderStatus({required this.item, required this.onTap});
  final _OrderItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: SizedBox(
      width: 64,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: AppColors.accent, size: 24),
              ),
              if (item.count != null)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: item.badgeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.count!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.label.tr,
            maxLines: 1,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.title,
    required this.items,
    required this.onTap,
  });
  final String title;
  final List<_MenuItem> items;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            title.tr,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D1F2937),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  InkWell(
                    onTap: item.onToggle == null
                        ? () => onTap(item.label)
                        : null,
                    child: SizedBox(
                      height: 56,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(item.icon, size: 20, color: AppColors.accent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.label.tr,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (item.trailingText != null)
                              Text(
                                item.trailingText!.tr,
                                style: TextStyle(
                                  color: item.label == 'Hot Line'
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: item.label == 'Hot Line'
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            if (item.onToggle != null)
                              Switch(
                                key: const Key('profile-dark-mode'),
                                value: item.toggleValue ?? false,
                                onChanged: item.onToggle,
                                activeThumbColor: AppColors.primary,
                              )
                            else ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (index != items.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: ProfilePage._divider,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    ),
  );
}

class _MenuItem {
  const _MenuItem(
    this.icon,
    this.label, {
    this.trailingText,
    this.toggleValue,
    this.onToggle,
  });

  final IconData icon;
  final String label;
  final String? trailingText;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
}
