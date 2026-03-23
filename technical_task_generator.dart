import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class TechnicalTaskGenerator {
  static Future<void> generate({
    required BuildContext context,
    required String roomName,
    required double cornice,
    required double height,
    required double coef,
    required double topHem,
    required double bottomHem,
    required double leftHem,
    required double rightHem,
    required int panels,
    required double fabricMeters,
    required double sewingCostSeamstress,
    required Map<String, dynamic> options,
    required String techComment,
    required bool isHandFold,
    required bool isTape,
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

      // HEADER
      _drawTZHeader(canvas, size);

      double y = 160;

      // ORDER INFO
      final orderNumber =
          '${roomName}_${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}';
      
      // ✅ ИСПРАВЛЕНО: закрыта кавычка после $orderNumber
      _drawText(canvas, 'Заказ №$orderNumber', 80, y,
          fontSize: 22, fontWeight: FontWeight.bold);
      
      _drawText(canvas, 'Комната: $roomName', 80, y + 35,
          fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346));
      _drawText(canvas, 'Дизайнер: МАРИЯ', 80, y + 60,
          fontSize: 14, color: Colors.grey);
      _drawText(
          canvas,
          'Срок сдачи: ${DateFormat('dd.MM.yy').format(DateTime.now().add(const Duration(days: 7)))}',
          80,
          y + 85,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF8B2346));

      y += 150;

      // PARAMETERS TABLE
      y = _drawParametersTable(
        canvas,
        y.toInt(),
        cornice,
        height,
        coef,
        topHem,
        bottomHem,
        leftHem,
        rightHem,
        panels,
        fabricMeters,
      ).toDouble();

      y += 40;

      // CUTTING SKETCH
      y = _drawCuttingSketch(
        canvas,
        y.toInt(),
        cornice,
        height,
        topHem,
        bottomHem,
      ).toDouble();

      y += 40;

      // OPTIONS
      if (isHandFold || isTape || techComment.isNotEmpty) {
        y = _drawOptions(canvas, y.toInt(), isHandFold, isTape, techComment)
            .toDouble();
      }

      y += 40;

      // FOOTER
      _drawTZFooter(canvas, size, y.toInt());

      // ✅ КОНВЕРТИРУЕМ В JPG
      final picture = recorder.endRecording();
      final image =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        final decodedImage = img.decodePng(pngBytes);

        if (decodedImage != null) {
          final jpgBytes = img.encodeJpg(decodedImage, quality: 95);

          final dir = await getApplicationDocumentsDirectory();
          final fileName =
              'TZ_${roomName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final file = File('${dir.path}/$fileName');
          await file.writeAsBytes(jpgBytes);

          await Share.shareXFiles(
            [XFile(file.path, mimeType: 'image/jpeg')],
            text: 'Техническое задание - $roomName',
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ТЗ создано (JPG): $fileName'),
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
      print('TZ Error: $e');
    }
  }

  static void _drawTZHeader(Canvas canvas, ui.Size size) {
    // Header background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 120),
      Paint()..color = const Color(0xFFF5F5F5),
    );

    // Logo circle
    canvas.drawCircle(
      const Offset(80, 60),
      35,
      Paint()
        ..color = Colors.transparent
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF8B2346),
    );

    final logoPainter = TextPainter(
      text: const TextSpan(
        text: 'М',
        style: TextStyle(
          color: Color(0xFF8B2346),
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
      // ✅ ИСПРАВЛЕНО: rtl → ltr (для латиницы/кириллицы)
      textDirection: ui.TextDirection.ltr,
    );
    logoPainter.layout();
    logoPainter.paint(canvas, const Offset(60, 40));

    // Title
    _drawText(canvas, 'ТЕХНИЧЕСКОЕ ЗАДАНИЕ', 200, 40,
        fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346));

    // Subtitle
    _drawText(canvas, 'Студия текстильного дизайна МАРТ', 200, 75,
        fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic);
  }

  static int _drawParametersTable(
    Canvas canvas,
    int yPos,
    double cornice,
    double height,
    double coef,
    double topHem,
    double bottomHem,
    double leftHem,
    double rightHem,
    int panels,
    double fabricMeters,
  ) {
    _drawText(canvas, 'ПАРАМЕТРЫ ИЗДЕЛИЯ', 80, yPos.toDouble(),
        fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346));

    yPos += 35;

    final data = [
      ['Ширина карниза', '${cornice.toStringAsFixed(0)} см'],
      ['Высота', '${height.toStringAsFixed(0)} см'],
      ['Коэффициент сборки', '${coef.toStringAsFixed(1)}x'],
      ['Подгибы (верх/низ)', '${topHem.toStringAsFixed(0)} / ${bottomHem.toStringAsFixed(0)} см'],
      ['Подгибы (лево/право)', '${leftHem.toStringAsFixed(0)} / ${rightHem.toStringAsFixed(0)} см'],
      ['Полотен', '$panels шт'],
      ['Метраж ткани', '${fabricMeters.toStringAsFixed(1)} м'],
    ];

    const int rowHeight = 35;
    const int col1Width = 550;
    const int col2Width = 400;

    for (var row in data) {
      canvas.drawRect(
        Rect.fromLTWH(80, yPos.toDouble(), col1Width.toDouble(), rowHeight.toDouble()),
        Paint()..color = Colors.grey.shade200,
      );
      canvas.drawRect(
        Rect.fromLTWH(80, yPos.toDouble(), col1Width.toDouble(), rowHeight.toDouble()),
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke,
      );

      _drawText(canvas, row[0], 100, (yPos + 17).toDouble(), fontSize: 13);

      canvas.drawRect(
        Rect.fromLTWH(
          (80 + col1Width).toDouble(),
          yPos.toDouble(),
          col2Width.toDouble(),
          rowHeight.toDouble(),
        ),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          (80 + col1Width).toDouble(),
          yPos.toDouble(),
          col2Width.toDouble(),
          rowHeight.toDouble(),
        ),
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke,
      );

      _drawText(canvas, row[1], (100 + col1Width).toDouble(), (yPos + 17).toDouble(),
          fontSize: 13, fontWeight: FontWeight.bold);

      yPos += rowHeight;
    }

    return yPos;
  }

  static int _drawCuttingSketch(
    Canvas canvas,
    int yPos,
    double cornice,
    double height,
    double topHem,
    double bottomHem,
  ) {
    _drawText(canvas, 'СХЕМА РАСКРОЯ', 80, yPos.toDouble(),
        fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346));

    yPos += 40;

    const int rectX = 400;
    const int rectW = 200;
    const int rectH = 300;

    // Основной прямоугольник
    canvas.drawRect(
      Rect.fromLTWH(rectX.toDouble(), yPos.toDouble(), rectW.toDouble(), rectH.toDouble()),
      Paint()
        ..color = Colors.transparent
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF8B2346),
    );

    // Размеры
    _drawText(canvas, '${cornice.toStringAsFixed(0)} см', (rectX + rectW / 2).toDouble(), (yPos - 30).toDouble(),
        fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346), align: TextAlign.center);

    _drawText(canvas, '${height.toStringAsFixed(0)} см', (rectX - 60).toDouble(), (yPos + rectH / 2).toDouble(),
        fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346), align: TextAlign.center);

    // Подписи
    _drawText(canvas, 'Верх ${topHem.toStringAsFixed(0)} см', (rectX + 50).toDouble(), (yPos + 20).toDouble(),
        fontSize: 12, color: Colors.grey);

    _drawText(canvas, 'Низ ${bottomHem.toStringAsFixed(0)} см', (rectX + 50).toDouble(), (yPos + rectH - 25).toDouble(),
        fontSize: 12, color: Colors.grey);

    return yPos + rectH + 40;
  }

  static int _drawOptions(
    Canvas canvas,
    int yPos,
    bool isHandFold,
    bool isTape,
    String techComment,
  ) {
    _drawText(canvas, 'СПЕЦИАЛЬНЫЕ ТРЕБОВАНИЯ', 80, yPos.toDouble(),
        fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346));

    yPos += 35;

    if (isHandFold) {
      _drawText(canvas, '✓ Ручная складка', 100, yPos.toDouble(), fontSize: 14);
      yPos += 25;
    }

    if (isTape) {
      _drawText(canvas, '✓ Шторная лента', 100, yPos.toDouble(), fontSize: 14);
      yPos += 25;
    }

    if (techComment.isNotEmpty) {
      _drawText(canvas, 'Примечание: $techComment', 100, yPos.toDouble(), fontSize: 12, color: Colors.grey);
      yPos += 30;
    }

    return yPos;
  }

  static void _drawTZFooter(Canvas canvas, ui.Size size, int yPos) {
    // Line
    canvas.drawLine(
      Offset(80, yPos.toDouble()),
      Offset(size.width - 80, yPos.toDouble()),
      Paint()
        ..color = Colors.grey.shade300
        ..strokeWidth = 1,
    );

    yPos += 20;

    _drawText(canvas, 'Лесной, ул. Пушкина 8Б, Пушкино', 80, yPos.toDouble(),
        fontSize: 11, color: Colors.grey);
    _drawText(canvas, 'Тел: +7 (977) 892-08-32 | Email: shtory.mart@yandex.ru', 80, (yPos + 20).toDouble(),
        fontSize: 11, color: const Color(0xFF8B2346));
    _drawText(canvas, 'Сайт: https://mart.see.ru  ', 80, (yPos + 40).toDouble(),
        fontSize: 11, color: const Color(0xFF8B2346));
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
    FontStyle fontStyle = FontStyle.normal,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
        ),
      ),
      // ✅ ИСПРАВЛЕНО: rtl → ltr (русский текст читается слева направо)
      textDirection: ui.TextDirection.ltr,
      textAlign: align,
      maxLines: 2,
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