import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app/theme/app_colors.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});
  void action(String value) => Get.snackbar(
    value,
    '$value is ready to connect.',
    snackPosition: SnackPosition.BOTTOM,
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        'Contact Us'.tr,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    ),
    body: ListView(
      children: [
        Image.asset(
          'assets/images/contact/storefront.png',
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    _ContactRow(
                      Icons.phone_outlined,
                      Color(0xFFEEF2FF),
                      '09-123-456-789',
                      '09-987-654-321',
                    ),
                    Divider(height: 1),
                    _ContactRow(
                      Icons.mail_outline,
                      Color(0xFFFDF2F8),
                      'hello@hexcystationery.com',
                      'support@hexcystationery.com',
                    ),
                    Divider(height: 1),
                    _ContactRow(
                      Icons.location_on_outlined,
                      Color(0xFFF0FDF4),
                      'No.25, Main Street',
                      'Sanchaung Township, Yangon\nGet Directions →',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Stack(
                  children: [
                    CustomPaint(painter: _GridPainter(), size: Size.infinite),
                    const Center(
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0x331E1B4B),
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 12,
                      bottom: 12,
                      child: _Pill('HEXY STATIONERY'),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: InkWell(
                        onTap: () => action('Open in Maps'),
                        child: const _Pill('➤ Open in Maps'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Social(
                    'FB Page',
                    const Color(0xFF1877F2),
                    Icons.facebook,
                    action,
                  ),
                  const SizedBox(width: 8),
                  _Social(
                    'Viber Call',
                    const Color(0xFF7360F2),
                    Icons.phone,
                    action,
                  ),
                  const SizedBox(width: 8),
                  _Social('TikTok', Colors.black, Icons.play_arrow, action),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ContactRow extends StatelessWidget {
  const _ContactRow(this.icon, this.color, this.title, this.subtitle);
  final IconData icon;
  final Color color;
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 80,
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: AppColors.accent),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle.tr,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6)],
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _Social extends StatelessWidget {
  const _Social(this.label, this.color, this.icon, this.onTap);
  final String label;
  final Color color;
  final IconData icon;
  final ValueChanged<String> onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: SizedBox(
      height: 44,
      child: FilledButton.icon(
        onPressed: () => onTap(label),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icon, size: 17),
        label: Text(label.tr, style: const TextStyle(fontSize: 12)),
      ),
    ),
  );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFFE5E7EB);
    for (double x = 0; x < size.width; x += size.width / 5) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += size.height / 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
