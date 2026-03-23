import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class PeriodicNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        print('Notification tapped: ${response.payload}');
      },
    );

    // ✅ Запускаем ежедневные напоминания
    _scheduleDaily(9, 0);   // 09:00
    _scheduleDaily(13, 0);  // 13:00
  }

  /// Планирует ежедневное уведомление
  static Future<void> _scheduleDaily(int hour, int minute) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        hour * 100 + minute,
        '⏰ Проверьте заказы',
        'Активные комнаты в работе',
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_notifications',
            'Ежедневные напоминания',
            channelDescription: 'Напоминания о заказах в 09:00 и 13:00',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      print('✅ Уведомление на $hour:$minute запланировано');
    } catch (e) {
      print('❌ Ошибка при планировании уведомления: $e');
    }
  }

  /// Получает с��едующее время для напоминания
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Уведомления за 3 дня и за 1 день до срока
  static Future<void> scheduleDeadlineNotifications({
    required String clientName,
    required String roomName,
    required DateTime clientDeadline,
    required DateTime seamstressDeadline,
  }) async {
    final now = DateTime.now();

    // За 3 дня до срока клиента
    final threeDaysBeforeClient = clientDeadline.subtract(const Duration(days: 3));
    if (threeDaysBeforeClient.isAfter(now)) {
      await _notificationsPlugin.zonedSchedule(
        clientDeadline.millisecondsSinceEpoch ~/ 1000,
        '⏰ За 3 дня до срока',
        'Клиент: $clientName • $roomName',
        tz.TZDateTime.from(threeDaysBeforeClient, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'deadline_3days',
            'Напоминание за 3 дня',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }

    // За 1 день до срока клиента
    final oneDayBeforeClient = clientDeadline.subtract(const Duration(days: 1));
    if (oneDayBeforeClient.isAfter(now)) {
      await _notificationsPlugin.zonedSchedule(
        clientDeadline.millisecondsSinceEpoch ~/ 100,
        '⏰ За день до срока',
        'Клиент: $clientName • $roomName',
        tz.TZDateTime.from(oneDayBeforeClient, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'deadline_1day',
            'Напоминание за день',
            importance: Importance.max,
            priority: Priority.max,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }

    print('✅ Уведомления о сроках запланированы');
  }

  /// Отправляет одноразовое уведомление
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    try {
      await _notificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'instant_notifications',
            'Уведомления',
            importance: Importance.max,
            priority: Priority.max,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
      print('✅ Уведомление отправлено: $title');
    } catch (e) {
      print('❌ Ошибка при отправке уведомления: $e');
    }
  }
}