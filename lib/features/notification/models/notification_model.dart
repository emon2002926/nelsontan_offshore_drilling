// features/notifications/data/models/notification_model.dart
// features/notifications/data/models/notification_model.dart
class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String subtitle; // For "Fire in Rig Floor"
  final String message;
  final String? fullMessage;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle = '',
    required this.message,
    this.fullMessage,
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'info',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      message: json['message'] ?? '',
      fullMessage: json['full_message'],
      imageUrl: json['image_url'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'message': message,
      'full_message': fullMessage,
      'image_url': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
    };
  }

  static List<NotificationModel> dummies() {
    return [
      NotificationModel(
        id: '1',
        type: 'reminder',
        title: 'Reminder!',
        message: 'Please submit your card before the day ends.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      NotificationModel(
        id: '2',
        type: 'alert',
        title: 'Alert!',
        subtitle: 'Fire in Rig Floor',
        message: 'A fire has been reported on the rig floor, posing an immediate...',
        fullMessage: '''A fire has been detected on the rig floor area. This is a critical safety alert that requires immediate attention. All personnel should remain alert and follow emergency procedures. Access to the rig floor may be restricted until the situation is under control. Emergency response teams may be deployed to manage the incident. Please prioritize safety and avoid the affected zone. Further updates will be provided as more information becomes available.''',
        imageUrl: null,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}