class NotificationUtil {
  static init() async {}
  static Future<void> closeNotification(int id) async {}
  static Future<void> sendProgressNotification(
    int id,
    int progress, {
    String? title,
    String? payload,
  }) async {}
  static Future<void> sendInfoNotification(
    int id,
    String title,
    String body, {
    String? payload,
  }) async {}
}
var notification = NotificationUtil();
