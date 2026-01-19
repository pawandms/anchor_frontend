class NotificationSettings {
  final bool msgNotification;
  final bool groupNotificaiton;
  final bool callNotificaiton;
  final bool statusNotification;

  NotificationSettings({
    required this.msgNotification,
    required this.groupNotificaiton,
    required this.callNotificaiton,
    required this.statusNotification,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      msgNotification: json['msgNotification'] ?? true,
      groupNotificaiton: json['groupNotificaiton'] ?? true,
      callNotificaiton: json['callNotificaiton'] ?? true,
      statusNotification: json['statusNotification'] ?? true,
    );
  }
}
