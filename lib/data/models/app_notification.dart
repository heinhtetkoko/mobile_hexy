class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.isRead,
    this.type,
    this.imageUrl,
  });
  final String id;
  final String title;
  final String message;
  final String date;
  final bool isRead;
  final String? type;
  final String? imageUrl;

  factory AppNotification.fromJson(Map<dynamic, dynamic> json) {
    final content = json['content'];
    final source = content is Map ? {...json, ...content} : json;
    return AppNotification(
      id: (source['id'] ?? source['notification_id'])?.toString() ?? '',
      title:
          (source['title'] ?? source['subject'] ?? source['name'])
              ?.toString() ??
          'Notification',
      message:
          (source['message'] ??
                  source['body'] ??
                  source['description'] ??
                  source['text'])
              ?.toString() ??
          '',
      date:
          (source['date'] ??
                  source['created_at'] ??
                  source['create_date'] ??
                  source['datetime'])
              ?.toString() ??
          '',
      isRead:
          source['is_read'] == true ||
          source['read'] == true ||
          source['status']?.toString().toLowerCase() == 'read',
      type: (source['type'] ?? source['category'])?.toString(),
      imageUrl: (source['image_url'] ?? source['image'])?.toString(),
    );
  }
}
