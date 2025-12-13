import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/bill_provider.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.actionId == 'MARK_PAID') {
          final billId = response.payload?.split(':').last;
          if (billId != null) {
            final context = navigatorKey.currentContext;
            if (context != null) {
              await Provider.of<BillProvider>(context, listen: false)
                  .markBillPaid(billId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Bill marked as paid from notification')),
              );
            }
          }
        }
      },
    );
  }

  static Future<void> scheduleBillReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'bill_reminder_channel',
          'Bill Reminders',
          channelDescription: 'Reminders for upcoming bills',
          importance: Importance.max,
          priority: Priority.high,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction('MARK_PAID', 'Mark as Paid'),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: 'bill_id:$id',
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> updateBillReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await cancelNotification(id);
    await scheduleBillReminder(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }

  static Future<void> snoozeNotification({
    required int id,
    required String title,
    required String body,
    required Duration snoozeDuration,
  }) async {
    final now = DateTime.now().add(snoozeDuration);
    await scheduleBillReminder(
      id: id,
      title: title,
      body: body,
      scheduledDate: now,
    );
  }
}
