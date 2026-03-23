import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:ui' as ui;

class InvoiceGenerator {
  static Future<void> generateClientInvoice({
    required BuildContext context,
    required String clientName,
    required String clientPhone,
    required List<Map<String, dynamic>> rooms,
    required double totalAmount,
  }) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = const ui.Size(1400, 1800);

      // WHITE BACKGROUND
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white,
      );

      // HEADER WITH COLOR
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, 140),
        Paint()..color = const Color(0xFF8B2346),
      );

      double y = 20;

      // ✅ ЛОГОТИП - кружок с М
      _drawLogo(canvas, 80, y, 100, 100);

      // COMPANY NAME
      _drawText(canvas, 'Студия текстильного дизайна МАРТ', 250, y + 30,
          fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white);

      // CONTACTS ON RIGHT
      _drawText(canvas, '+7 (977) 892-08-32', size.width - 80, y + 15,
          fontSize: 13, color: Colors.white, align: TextAlign.right);
      _drawText(canvas, 'shtory.mart@yandex.ru', size.width - 80, y + 38,
          fontSize: 13, color: Colors.white, align: TextAlign.right);
      _drawText(canvas, 'https://mart.see.ru', size.width - 80, y + 61,
          fontSize: 13, color: Colors.white, align: TextAlign.right);

      y = 170;

      // ADDRESS
      _drawText(canvas, 'Лесной, ул. Пушкина 8Б, Пушкино', 80, y,
          fontSize: 13, color: Colors.grey.shade700);
      y += 50;

      // INVOICE TITLE
      _drawText(canvas, 'СЧЕТ НА ОПЛАТУ', 80, y,
          fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346));
      y += 60;

      // INVOICE NUMBER AND DATE
      _drawText(canvas, 'Счет №: ${DateTime.now().millisecondsSinceEpoch ~/ 1000}', 80, y,
          fontSize: 12, color: Colors.grey);
      _drawText(canvas, 'Дата: ${DateTime.now().toString().split(' ')[0]}', 80, y + 25,
          fontSize: 12, color: Colors.grey);
      y += 70;

      // CLIENT INFO BOX
      canvas.drawRect(
        Rect.fromLTWH(80, y, 500, 90),
        Paint()..color = Colors.grey.shade100,
      );
      canvas.drawRect(
        Rect.fromLTWH(80, y, 500, 90),
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );

      _drawText(canvas, 'КЛИЕНТ:', 100, y + 15,
          fontSize: 12, fontWeight: FontWeight.bold);
      _drawText(canvas, clientName, 100, y + 35,
          fontSize: 16, fontWeight: FontWeight.bold);
      _drawText(canvas, 'Телефон: $clientPhone', 100, y + 60,
          fontSize: 12);

      y += 120;

      // TABLE HEADER
      final headerPaint = Paint()..color = const Color(0xFF8B2346);
      canvas.drawRect(
        Rect.fromLTWH(80, y, size.width - 160, 50),
        headerPaint,
      );

      _drawText(canvas, 'N', 110, y + 25, fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, align: TextAlign.center);
      _drawText(canvas, 'Описание работ', 200, y + 25, fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white);
      _drawText(canvas, 'Кол-во м', 850, y + 25, fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, align: TextAlign.center);
      _drawText(canvas, 'Сумма', 1100, y + 25, fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, align: TextAlign.center);

      y += 55;

      // TABLE ROWS
      int index = 1;
      for (var room in rooms) {
        final rowColor = index.isEven ? Colors.grey.shade50 : Colors.white;
        canvas.drawRect(
          Rect.fromLTWH(80, y, size.width - 160, 45),
          Paint()..color = rowColor,
        );

        canvas.drawRect(
          Rect.fromLTWH(80, y, size.width - 160, 45),
          Paint()
            ..color = Colors.grey.shade300
            ..strokeWidth = 0.5
            ..style = PaintingStyle.stroke,
        );

        _drawText(canvas, index.toString(), 110, y + 22, fontSize: 12, align: TextAlign.center);
        _drawText(canvas, room['name'] ?? 'Комната', 200, y + 22, fontSize: 12);
        _drawText(canvas, room['fabricMeters'].toStringAsFixed(2), 850, y + 22, fontSize: 12, align: TextAlign.center);
        _drawText(canvas, '${room['clientPrice'].toStringAsFixed(0)} руб', 1100, y + 22,
            fontSize: 13, fontWeight: FontWeight.bold, align: TextAlign.center, color: Colors.green);

        y += 45;
        index++;
      }

      y += 20;

      // TOTAL BOX
      canvas.drawRect(
        Rect.fromLTWH(80, y, size.width - 160, 70),
        Paint()..color = const Color(0xFF8B2346).withOpacity(0.15),
      );
      canvas.drawRect(
        Rect.fromLTWH(80, y, size.width - 160, 70),
        Paint()
          ..color = const Color(0xFF8B2346)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );

      _drawText(canvas, 'ИТОГО К ОПЛАТЕ:', 850, y + 35, fontSize: 16, fontWeight: FontWeight.bold);
      _drawText(canvas, '${totalAmount.toStringAsFixed(0)} руб', 1100, y + 35,
          fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346), align: TextAlign.center);

      y += 110;

      // FOOTER NOTES
      _drawText(canvas, '📝 Примечание:', 80, y, fontSize: 12, fontWeight: FontWeight.bold);
      _drawText(canvas, 'Счет действителен 30 дней с момента выставления.', 80, y + 25, fontSize: 11, color: Colors.grey);
      _drawText(canvas, 'Оплата производится на расчетный счет компании.', 80, y + 45, fontSize: 11, color: Colors.grey);

      y += 90;

      // THANK YOU
      _drawText(canvas, '✨ Спасибо за доверие! ✨', size.width / 2, y,
          fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346), align: TextAlign.center);

      // ✅ КОНВЕРТИРУЕМ В JPG
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        // Декодируем PNG
        final pngBytes = byteData.buffer.asUint8List();
        final decodedImage = img.decodePng(pngBytes);

        // Энкодируем в JPG
        if (decodedImage != null) {
          final jpgBytes = img.encodeJpg(decodedImage, quality: 95);
          
          final dir = await getApplicationDocumentsDirectory();
          final fileName = 'Schet_${clientName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final file = File('${dir.path}/$fileName');
          await file.writeAsBytes(jpgBytes);

          await Share.shareXFiles(
            [XFile(file.path, mimeType: 'image/jpeg')],
            text: 'Счет на оплату от МАРТ ПРО 8',
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ��чет создан (JPG): $fileName'),
                duration: const Duration(seconds: 5),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Invoice Error: $e');
    }
  }

  // ✅ ЛОГОТИП - кружок с буквой М
  static void _drawLogo(Canvas canvas, double x, double y, double width, double height) {
    // Круг бордовый
    canvas.drawCircle(
      Offset(x + width / 2, y + height / 2),
      width / 2,
      Paint()..color = Colors.white.withOpacity(0.2),
    );

    // Бордер круга
    canvas.drawCircle(
      Offset(x + width / 2, y + height / 2),
      width / 2,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // Текст логотипа - большая буква М
    final logoPainter = TextPainter(
      text: const TextSpan(
        text: 'М',
        style: TextStyle(
          color: Colors.white,
          fontSize: 56,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    logoPainter.layout();
    logoPainter.paint(
      canvas,
      Offset(
        x + (width - logoPainter.width) / 2,
        y + (height - logoPainter.height) / 2 - 5,
      ),
    );
  }

  static void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
    TextAlign align = TextAlign.left,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: fontWeight),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    );
    textPainter.layout(maxWidth: 900);

    double offsetX;
    if (align == TextAlign.center) {
      offsetX = x - textPainter.width / 2;
    } else if (align == TextAlign.right) {
      offsetX = x - textPainter.width;
    } else {
      offsetX = x;
    }

    textPainter.paint(canvas, Offset(offsetX, y - textPainter.height / 2));
  }
}