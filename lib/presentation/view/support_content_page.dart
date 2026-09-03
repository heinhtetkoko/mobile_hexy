import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/data/datasources/support_content_remote_data_source.dart';
import 'package:mobile_hexy/presentation/widgets/clean_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

enum SupportContentType { contact, faq, document }

Future<void> _openContactLink(Uri uri, {required String label}) async {
  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened) return;
  } catch (_) {
    // The message below handles missing apps and invalid external links.
  }

  Get.snackbar(
    'Unable to open $label',
    'Please make sure $label is installed and try again.',
    snackPosition: SnackPosition.BOTTOM,
  );
}

class SupportContentPage extends StatefulWidget {
  const SupportContentPage({
    super.key,
    required this.title,
    required this.path,
    required this.type,
  });

  const SupportContentPage.contact({super.key})
    : title = 'Contact Us',
      path = ApiEndpoints.contactUs,
      type = SupportContentType.contact;

  const SupportContentPage.faq({super.key})
    : title = 'FAQ',
      path = ApiEndpoints.faqs,
      type = SupportContentType.faq;

  const SupportContentPage.about({super.key})
    : title = 'About Us',
      path = ApiEndpoints.aboutUs,
      type = SupportContentType.document;

  const SupportContentPage.privacy({super.key})
    : title = 'Privacy Policy',
      path = ApiEndpoints.privacyPolicy,
      type = SupportContentType.document;

  const SupportContentPage.terms({super.key})
    : title = 'Terms & Conditions',
      path = ApiEndpoints.termsConditions,
      type = SupportContentType.document;

  final String title;
  final String path;
  final SupportContentType type;

  @override
  State<SupportContentPage> createState() => _SupportContentPageState();
}

class _SupportContentPageState extends State<SupportContentPage> {
  late Future<Object> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = Get.find<SupportContentRemoteDataSource>().fetch(widget.path);
  }

  void _retry() => setState(_load);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CleanAppBar(title: widget.title),
    body: FutureBuilder<Object>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return _SupportError(error: snapshot.error, onRetry: _retry);
        }
        return switch (widget.type) {
          SupportContentType.contact => _ContactContent(data: snapshot.data!),
          SupportContentType.faq => _FaqContent(data: snapshot.data!),
          SupportContentType.document => _DocumentContent(data: snapshot.data!),
        };
      },
    ),
  );
}

class _ContactContent extends StatelessWidget {
  const _ContactContent({required this.data});
  final Object data;

  @override
  Widget build(BuildContext context) {
    final root = data is Map ? data as Map : const {};
    final nested = root['contact'];
    final map = nested is Map ? {...root, ...nested} : root;
    final phones = _contactValues(
      map['phones'] ?? map['phone_numbers'] ?? [map['phone'], map['hotline']],
    );
    final emails = _contactValues(
      map['emails'] ?? [map['email'], map['support_email']],
    );
    final address = _contactValues(map['address'] ?? map['full_address']);
    final heroUrl =
        (map['image_url'] ??
                map['store_image'] ??
                map['banner_image'] ??
                map['hero_image'])
            ?.toString();
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 230,
          width: double.infinity,
          child: heroUrl?.isNotEmpty == true
              ? Image.network(
                  heroUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Image.asset(
                    'assets/images/contact/storefront.png',
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  'assets/images/contact/storefront.png',
                  fit: BoxFit.cover,
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (phones.isNotEmpty)
                      _ContactDetailRow(
                        icon: Icons.phone_outlined,
                        iconColor: const Color(0xFF24205F),
                        iconBackground: const Color(0xFFF0F1FF),
                        values: phones,
                      ),
                    if (phones.isNotEmpty && emails.isNotEmpty)
                      const Divider(height: 1),
                    if (emails.isNotEmpty)
                      _ContactDetailRow(
                        icon: Icons.mail_outline_rounded,
                        iconColor: const Color(0xFFE91E75),
                        iconBackground: const Color(0xFFFFEDF5),
                        values: emails,
                      ),
                    if ((phones.isNotEmpty || emails.isNotEmpty) &&
                        address.isNotEmpty)
                      const Divider(height: 1),
                    if (address.isNotEmpty)
                      _ContactDetailRow(
                        icon: Icons.location_on_outlined,
                        iconColor: const Color(0xFF10B968),
                        iconBackground: const Color(0xFFEAFFF3),
                        values: [...address, 'Get Directions →'],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const _ContactMapCard(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ContactSocialButton(
                      label: 'FB Page',
                      icon: Icons.facebook,
                      color: Color(0xFF1877F2),
                      onPressed: () => _openContactLink(
                        Uri.parse('https://www.facebook.com/share/19ZDP3opBp/'),
                        label: 'Facebook',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ContactSocialButton(
                      label: 'Viber Call',
                      icon: Icons.phone_outlined,
                      color: Color(0xFF7354ED),
                      onPressed: () => _openContactLink(
                        Uri(
                          scheme: 'viber',
                          host: 'chat',
                          queryParameters: const {'number': '+959752473565'},
                        ),
                        label: 'Viber',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ContactSocialButton(
                      label: 'TikTok',
                      icon: Icons.play_arrow_rounded,
                      color: Colors.black,
                      onPressed: () => _openContactLink(
                        Uri.parse(
                          'https://www.tiktok.com/@hexcy.stationery?_r=1&_t=ZS-99Q8z9h6u2O',
                        ),
                        label: 'TikTok',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactDetailRow extends StatelessWidget {
  const _ContactDetailRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.values,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final List<String> values;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: iconBackground,
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: values.indexed.map((entry) {
              final (index, value) = entry;
              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : 3),
                child: Text(
                  _plain(value),
                  style: TextStyle(
                    color: index == 0
                        ? const Color(0xFF171725)
                        : const Color(0xFF7D8597),
                    fontSize: index == 0 ? 15 : 13,
                    fontWeight: index == 0 ? FontWeight.w800 : FontWeight.w400,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );
}

class _ContactMapCard extends StatelessWidget {
  const _ContactMapCard();

  @override
  Widget build(BuildContext context) => Container(
    height: 170,
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFD),
      border: Border.all(color: const Color(0xFFDDE3EC)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Stack(
      children: [
        CustomPaint(painter: _ContactGridPainter(), size: Size.infinite),
        const Center(
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Color(0x25242060),
            child: CircleAvatar(radius: 6, backgroundColor: Color(0xFF242060)),
          ),
        ),
        const Positioned(
          left: 12,
          bottom: 12,
          child: _ContactPill(label: 'HEXY STATIONERY'),
        ),
        const Positioned(
          right: 12,
          bottom: 12,
          child: _ContactPill(label: '➤ Open in Maps'),
        ),
      ],
    ),
  );
}

class _ContactPill extends StatelessWidget {
  const _ContactPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 6)],
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
    ),
  );
}

class _ContactSocialButton extends StatelessWidget {
  const _ContactSocialButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: color,
      disabledBackgroundColor: color.withValues(alpha: .55),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    icon: Icon(icon, size: 17),
    label: Text(
      label,
      maxLines: 1,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    ),
  );
}

class _ContactGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDDE3EC)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 72) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 30; y < size.height; y += 46) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

List<String> _contactValues(Object? value) {
  if (value == null || value == false) return const [];
  if (value is List) {
    return value
        .where((item) => item != null && item != false)
        .map(
          (item) => item is Map
              ? (item['value'] ??
                            item['number'] ??
                            item['email'] ??
                            item['name'])
                        ?.toString() ??
                    ''
              : item.toString(),
        )
        .where((item) => item.trim().isNotEmpty)
        .toList(growable: false);
  }
  return value.toString().trim().isEmpty ? const [] : [value.toString()];
}

class _FaqContent extends StatelessWidget {
  const _FaqContent({required this.data});
  final Object data;

  @override
  Widget build(BuildContext context) {
    final source = data is Map
        ? ((data as Map)['faqs'] ?? (data as Map)['items'] ?? data)
        : data;
    final items = source is List ? source.whereType<Map>().toList() : const [];
    if (items.isEmpty) return _DocumentContent(data: data);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final item = items[index];
        final question = (item['question'] ?? item['title'] ?? '').toString();
        final answer =
            (item['answer'] ?? item['content'] ?? item['description'] ?? '')
                .toString();
        return Card(
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            title: Text(
              _plain(question),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: SelectableText(_plain(answer)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DocumentContent extends StatelessWidget {
  const _DocumentContent({required this.data});
  final Object data;

  @override
  Widget build(BuildContext context) {
    final map = data is Map ? data as Map : const {};
    final sections = map['sections'];
    final title = (map['title'] ?? map['name'] ?? '').toString();
    final content =
        (map['content_plain'] ??
                map['content'] ??
                map['body'] ??
                map['description'] ??
                map['content_html'] ??
                (data is String ? data : ''))
            .toString();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (title.isNotEmpty) ...[
          Text(
            _plain(title),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
        ],
        if (content.isNotEmpty)
          SelectableText(
            _plain(content),
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
        if (sections is List)
          ...sections.whereType<Map>().map(
            (section) => Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _plain(
                      (section['title'] ?? section['heading'] ?? '').toString(),
                    ),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _plain(
                      (section['content'] ?? section['body'] ?? '').toString(),
                    ),
                    style: const TextStyle(height: 1.6),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SupportError extends StatelessWidget {
  const _SupportError({required this.error, required this.onRetry});
  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          error.toString().replaceFirst('Exception: ', ''),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: Text('Retry'.tr)),
      ],
    ),
  );
}

String _plain(String value) => value
    .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
    .replaceAll(RegExp(r'</p>|</li>|</h[1-6]>', caseSensitive: false), '\n')
    .replaceAll(RegExp('<[^>]*>'), '')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll(RegExp(r'\n{3,}'), '\n\n')
    .trim();
