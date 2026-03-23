import 'package:device_calendar/device_calendar.dart';

class CalendarService {
  static final DeviceCalendarPlugin _deviceCalendarPlugin =
      DeviceCalendarPlugin();

  // ✅ Запросить доступ к календарю
  static Future<bool> requestCalendarPermission() async {
    try {
      final permissionGranted =
          await _deviceCalendarPlugin.requestPermissions();
      return permissionGranted;
    } catch (e) {
      print('❌ Ошибка до��тупа к календарю: $e');
      return false;
    }
  }

  // ✅ Создать событие в календаре телефона
  static Future<bool> createEvent({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Получить список календарей
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      final calendars = calendarsResult.data ?? [];

      if (calendars.isEmpty) {
        print('❌ Нет доступных календарей');
        return false;
      }

      // Использовать первый доступный календарь
      final calendar = calendars.first;

      final event = Event(
        calendar.id,
        title: title,
        description: description,
        start: TZDateTime.from(startDate, tzUtc),
        end: TZDateTime.from(endDate, tzUtc),
      );

      final createEventResult = await _deviceCalendarPlugin.createEvent(
        calendar.id,
        event,
      );

      return createEventResult.isSuccess;
    } catch (e) {
      print('❌ Ошибка создания события: $e');
      return false;
    }
  }

  // ✅ Получить события из календаря
  static Future<List<Event>> getUpcomingEvents() async {
    try {
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      final calendars = calendarsResult.data ?? [];

      if (calendars.isEmpty) return [];

      final calendar = calendars.first;

      final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
        calendar.id,
        RetrieveEventsParams(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );

      return eventsResult.data ?? [];
    } catch (e) {
      print('❌ Ошибка получения событий: $e');
      return [];
    }
  }
}