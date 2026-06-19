import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static const _medicineChannelId   = 'medicine_reminders';
  static const _medicineChannelName = 'Medicine Reminders';
  static const _medicineChannelDesc = 'Reminders for taking your medicines on time';
  static const _fcmChannelId   = 'vision_care_fcm';
  static const _fcmChannelName = 'Vision Care Notifications';
  static const _fcmChannelDesc = 'General notifications from Vision Care';

  static Future<void> init() async {


    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission:  true,
      requestBadgePermission:  true,
      requestSoundPermission:  true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS:     iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );


    await _requestPermission();

    await _createChannels();
  }

  static Future<void> _requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }


  static Future<void> _createChannels() async {
    const medicineChannel = AndroidNotificationChannel(
      _medicineChannelId,
      _medicineChannelName,
      description: _medicineChannelDesc,
      importance:  Importance.max,
      playSound:   true,
    );

    const fcmChannel = AndroidNotificationChannel(
      _fcmChannelId,
      _fcmChannelName,
      description: _fcmChannelDesc,
      importance:  Importance.high,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(medicineChannel);
    await androidPlugin?.createNotificationChannel(fcmChannel);
  }


  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _fcmChannelId,
      _fcmChannelName,
      channelDescription: _fcmChannelDesc,
      importance:         Importance.high,
      priority:           Priority.high,
      icon:               '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS:     iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }


  static Future<void> scheduleMedicineReminder({
    required int      id,
    required String   medicineName,
    required DateTime scheduledTime,
    bool              repeatDaily = true,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _medicineChannelId,
      _medicineChannelName,
      channelDescription: _medicineChannelDesc,
      importance:         Importance.max,
      priority:           Priority.high,
      icon:               '@mipmap/ic_launcher',

    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS:     iosDetails,
    );

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    if (repeatDaily) {

      await _plugin.zonedSchedule(
        id,
        '💊 Medicine Reminder',
        'Time to take your $medicineName',
        _nextInstanceOfTime(scheduledTime.hour, scheduledTime.minute),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        payload: medicineName,
      );
    } else {

      await _plugin.zonedSchedule(
        id,
        '💊 Medicine Reminder',
        'Time to take your $medicineName',
        tzScheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        payload: medicineName,
      );
    }
  }


  static Future<void> cancelMedicineReminder({required int id}) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now  = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  static void _onNotificationTapped(NotificationResponse response) {

    debugPrint('Notification tapped: ${response.payload}');
  }
}