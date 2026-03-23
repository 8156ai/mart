import 'package:http/http.dart' as http;
import 'dart:convert';

class TelegramService {
  // ✅ ВАШИ ДАННЫЕ
  static const String _botToken = '8588116653:AAHBc2l0fMFwAUjVgzFPMuWdRjAMtA0gpKk';
  static const String _adminChatId = '2025900744'; // Ваш ID
  static const String _seamstressChatId = '1145572114'; // ID швеи

  /// ✅ Отправить напоминание о сроке
  static Future<void> sendReminder({
    required String clientName,
    required String roomName,
    required String deadline,
  }) async {
    final message = '''
🔔 <b>НАПОМИНАНИЕ О СРОКЕ</b>

👤 Клиент: <b>$clientName</b>
🏠 Комната: <b>$roomName</b>
📅 Срок: <b>$deadline</b>

⏰ Не забудьте выполнить заказ в срок!
    ''';

    await _sendMessage(_adminChatId, message);
    await _sendMessage(_seamstressChatId, message);
  }

  /// ✅ Отправить уведомление о новом заказе
  static Future<void> sendNewOrder({
    required String clientName,
    required String roomName,
    required double fabricMeters,
    required double clientPrice,
    required String deadline,
  }) async {
    final message = '''
✨ <b>НОВЫЙ ЗАКАЗ</b>

👤 Клиент: <b>$clientName</b>
🏠 Комната: <b>$roomName</b>
🧵 Ткань: <b>${fabricMeters.toStringAsFixed(2)} м</b>
💰 Стоимость: <b>${clientPrice.toStringAsFixed(0)} руб</b>
📅 Срок: <b>$deadline</b>

✅ Заказ добавлен в систему!
    ''';

    await _sendMessage(_adminChatId, message);
    await _sendMessage(_seamstressChatId, message);
  }

  /// ✅ Отправить уведомление об обновлении
  static Future<void> sendUpdate({
    required String clientName,
    required String roomName,
    required String updateText,
    required double fabricMeters,
    required double clientPrice,
    required String deadline,
  }) async {
    final message = '''
📝 <b>ОБНОВЛЕНИЕ ЗАКАЗА</b>

👤 Клиент: <b>$clientName</b>
🏠 Комната: <b>$roomName</b>
🧵 Ткань: <b>${fabricMeters.toStringAsFixed(2)} м</b>
💰 Стоимость: <b>${clientPrice.toStringAsFixed(0)} руб</b>
📅 Срок: <b>$deadline</b>

$updateText
    ''';

    await _sendMessage(_adminChatId, message);
    await _sendMessage(_seamstressChatId, message);
  }

  /// ✅ Внутренний метод для отправки сообщения
  static Future<void> _sendMessage(String chatId, String message) async {
    try {
      final url = Uri.parse('https://api.telegram.org/bot$_botToken/sendMessage');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': chatId,
          'text': message,
          'parse_mode': 'HTML',
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('Timeout', 408),
      );

      if (response.statusCode == 200) {
        print('✅ Telegram: сообщение отправлено в $chatId');
      } else {
        print('❌ Telegram ошибка: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Telegram исключение: $e');
    }
  }
}