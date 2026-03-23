import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class TechnicalTaskGenerator {
  static const String companyName = 'МАРТ';
  static const String companySubtitle = 'СТУДИЯ ТЕКСТИЛЬНОГО ДИЗАЙНА';
  static const String companyAddress = 'Лесной, ул. Пушкина 8Б, Пушкино';
  static const String companyPhone = '+7 (977) 892-08-32';
  static const String companyEmail = 'shtory.mart@yandex.ru';
  static const String companyWebsite = 'https://mart.see.ru/';
  static const Color brandColor = Color(0xFF8B2346);

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
      // 🎨 Рендерим Flutter Widget в картинку
      final pdfImage = await _renderTechnicalTask(
        roomName: roomName,
        cornice: cornice,
        height: height,
        coef: coef,
        topHem: topHem,
        bottomHem: bottomHem,
        leftHem: leftHem,
        rightHem: rightHem,
        panels: panels,
        fabricMeters: fabricMeters,
        sewingCostSeamstress: sewingCostSeamstress,
        techComment: techComment,
        isHandFold: isHandFold,
        isTape: isTape,
      );

      if (pdfImage == null) {
        throw Exception('Ошибка при рендеринге ТЗ');
      }

      // 💾 Сохранить JPG
      final jpgBytes = img.encodeJpg(pdfImage, quality: 95);
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'TZ_${roomName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(jpgBytes);

      // 📤 Поделиться
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/jpeg')],
        text: 'Техническое задание - $roomName',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ ТЗ создано (JPG) и о��правлено'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
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
      print('Error: $e');
    }
  }

  static Future<img.Image?> _renderTechnicalTask({
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
    required String techComment,
    required bool isHandFold,
    required bool isTape,
  }) async {
    try {
      // Размер A4: 2480x3508 px (210x297 мм при 300 DPI)
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const Rect.fromLTWH(0, 0, 1240, 1754));

      // Белый фон
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 1240, 1754),
        Paint()..color = Colors.white,
      );

      // ======= ЗАГОЛОВОК =======
      _drawHeader(canvas);

      // ======= ИНФОРМАЦИЯ О ЗАКАЗЕ =======
      int yPos = 180;
      _drawOrderInfo(canvas, yPos, roomName);
      yPos += 120;

      // ======= ТАБЛИЦА ПАРАМЕТРОВ =======
      yPos = _drawParametersTable(
        canvas,
        yPos,
        cornice,
        height,
        coef,
        topHem,
        bottomHem,
        leftHem,
        rightHem,
        panels,
        fabricMeters,
      );
      yPos += 40;

      // ======= ЧЕРТЁЖ РАСКРОЯ =======
      yPos = _drawCuttingSketch(
        canvas,
        yPos,
        cornice,
        height,
        topHem,
        bottomHem,
        leftHem,
        rightHem,
      );
      yPos += 40;

      // ======= ОПЦИИ =======
      if (isHandFold || isTape || techComment.isNotEmpty) {
        _drawOptions(canvas, yPos, isHandFold, isTape, techComment);
        yPos += 80;
      }

      // ======= ПОДВАЛ =======
      _drawFooter(canvas, yPos);

      // Конвертируем в картинку
      final picture = recorder.endRecording();
      final image = await picture.toImage(1240, 1754);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Декодируем PNG и возвращаем как img.Image
      return img.decodePng(pngBytes);
    } catch (e) {
      print('Render error: $e');
      return null;
    }
  }

  static void _drawHeader(ui.Canvas canvas) {
    // Логотип плейсхолдер (кружок)
    canvas.drawCircle(
      const Offset(100, 80),
      40,
      Paint()
        ..color = const Color(0xFF8B2346)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Заголовок
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: 'ТЕХНИЧЕСКОЕ ЗАДАНИЕ',
        style: TextStyle(
          color: Color(0xFF8B2346),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, const Offset(250, 60));

    // Подзаголовок
    final subtitlePainter = TextPainter(
      text: const TextSpan(
        text: 'Студия текстильного дизай��а МАРТ',
        style: TextStyle(
          color: Color(0xFF8B2346),
          fontSize: 18,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    subtitlePainter.layout();
    subtitlePainter.paint(canvas, const Offset(250, 100));

    // Линия
    canvas.drawLine(
      const Offset(20, 150),
      const Offset(1220, 150),
      Paint()
        ..color = const Color(0xFF8B2346)
        ..strokeWidth = 2,
    );
  }

  static void _drawOrderInfo(ui.Canvas canvas, int yPos, String roomName) {
    final orderNumber =
        '${roomName}_${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}';

    final orderPainter = TextPainter(
      text: TextSpan(
        text: 'Заказ №$orderNumber',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    orderPainter.layout();
    orderPainter.paint(canvas, Offset(40, yPos.toDouble()));

    final designerPainter = TextPainter(
      text: const TextSpan(
        text: 'Дизайнер: МАРИЯ',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    designerPainter.layout();
    designerPainter.paint(canvas, Offset(40, (yPos + 35).toDouble()));

    final deadlinePainter = TextPainter(
      text: TextSpan(
        text:
            'Срок сдачи: ${DateFormat('dd.MM.yy').format(DateTime.now().add(const Duration(days: 7)))}',
        style: const TextStyle(
          color: Color(0xFF8B2346),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    deadlinePainter.layout();
    deadlinePainter.paint(canvas, Offset(40, (yPos + 60).toDouble()));
  }

  static int _drawParametersTable(
    ui.Canvas canvas,
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
    // Заголовок таблицы
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: 'ПАРАМЕТРЫ ИЗДЕЛИЯ',
        style: TextStyle(
          color: Color(0xFF8B2346),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, Offset(40, yPos.toDouble()));

    yPos += 40;

    final data = [
      ['Ширина карниза', '${cornice.toStringAsFixed(0)} см'],
      ['Высота', '${height.toStringAsFixed(0)} см'],
      ['Коэффициент', '${coef.toStringAsFixed(1)}x'],
      ['Подгибы (в/н)', '${topHem.toStringAsFixed(0)} / ${bottomHem.toStringAsFixed(0)} см'],
      ['Подгибы (л/п)', '${leftHem.toStringAsFixed(0)} / ${rightHem.toStringAsFixed(0)} см'],
      ['Полотен', '$panels шт'],
      ['Метраж ткани', '${fabricMeters.toStringAsFixed(1)} м'],
    ];

    const int rowHeight = 28;
    const int col1Width = 400;
    const int col2Width = 350;

    for (var row in data) {
      // Ячейка 1
      canvas.drawRect(
        Rect.fromLTWH(
          40,
          yPos.toDouble(),
          col1Width.toDouble(),
          rowHeight.toDouble(),
        ),
        Paint()..color = Colors.grey[200]!,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          40,
          yPos.toDouble(),
          col1Width.toDouble(),
          rowHeight.toDouble(),
        ),
        Paint()
          ..color = Colors.transparent
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke
          ..color = Colors.grey[400]!,
      );

      final cell1Painter = TextPainter(
        text: TextSpan(
          text: row[0],
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        textDirection: TextDirection.ltr,
      );
      cell1Painter.layout();
      cell1Painter.paint(canvas, Offset(55, (yPos + 6).toDouble()));

      // Ячейка 2
      canvas.drawRect(
        Rect.fromLTWH(
          40 + col1Width,
          yPos.toDouble(),
          col2Width.toDouble(),
          rowHeight.toDouble(),
        ),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          40 + col1Width,
          yPos.toDouble(),
          col2Width.toDouble(),
          rowHeight.toDouble(),
        ),
        Paint()
          ..color = Colors.transparent
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke
          ..color = Colors.grey[400]!,
      );

      final cell2Painter = TextPainter(
        text: TextSpan(
          text: row[1],
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      cell2Painter.layout();
      cell2Painter.paint(
        canvas,
        Offset(40 + col1Width + 15, (yPos + 6).toDouble()),
      );

      yPos += rowHeight;
    }

    return yPos + 10;
  }

  static int _drawCuttingSketch(
    ui.Canvas canvas,
    int yPos,
    double cornice,
    double height,
    double topHem,
    double bottomHem,
    double leftHem,
    double rightHem,
  ) {
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: 'СХЕМА РАСКРОЯ',
        style: TextStyle(
          color: Color(0xFF8B2346),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, Offset(40, yPos.toDouble()));

    yPos += 40;

    const int rectX = 300;
    const int rectY = yPos;
    const int rectW = 200;
    const int rectH = 280;

    // Основной прямоугольник
    canvas.drawRect(
      Rect.fromLTWH(
        rectX.toDouble(),
        rectY.toDouble(),
        rectW.toDouble(),
        rectH.toDouble(),
      ),
      Paint()
        ..color = Colors.transparent
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF8B2346),
    );

    // Размеры с стрелками
    _drawDimensionWithArrow(
      canvas,
      startX: rectX - 80,
      startY: rectY,
      length: rectH,
      label: '${height.toStringAsFixed(0)}см',
      vertical: true,
    );

    _drawDimensionWithArrow(
      canvas,
      startX: rectX,
      startY: rectY - 40,
      length: rectW,
      label: '${cornice.toStringAsFixed(0)}см',
      vertical: false,
    );

    // Подписи подгибов
    final topHemPainter = TextPainter(
      text: TextSpan(
        text: 'Верх ${topHem.toStringAsFixed(0)}',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      textDirection: TextDirection.ltr,
    );
    topHemPainter.layout();
    topHemPainter.paint(canvas, Offset(rectX + 20, (rectY + 10).toDouble()));

    final bottomHemPainter = TextPainter(
      text: TextSpan(
        text: 'Низ ${bottomHem.toStringAsFixed(0)}',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      textDirection: TextDirection.ltr,
    );
    bottomHemPainter.layout();
    bottomHemPainter.paint(
      canvas,
      Offset(rectX + 20, (rectY + rectH - 25).toDouble()),
    );

    return rectY + rectH + 40;
  }

  static void _drawDimensionWithArrow({
    required ui.Canvas canvas,
    required int startX,
    required int startY,
    required int length,
    required String label,
    required bool vertical,
  }) {
    const paint = Paint()
      ..color = Color(0xFF8B2346)
      ..strokeWidth = 2;

    if (vertical) {
      // Вертикальная линия
      canvas.drawLine(
        Offset(startX.toDouble(), startY.toDouble()),
        Offset(startX.toDouble(), (startY + length).toDouble()),
        paint,
      );
      // Стрелки
      canvas.drawLine(
        Offset((startX - 8).toDouble(), (startY + 8).toDouble()),
        Offset(startX.toDouble(), startY.toDouble()),
        paint,
      );
      canvas.drawLine(
        Offset((startX - 8).toDouble(), (startY + length - 8).toDouble()),
        Offset(startX.toDouble(), (startY + length).toDouble()),
        paint,
      );
    } else {
      // Горизонтальная линия
      canvas.drawLine(
        Offset(startX.toDouble(), startY.toDouble()),
        Offset((startX + length).toDouble(), startY.toDouble()),
        paint,
      );
      // Стрелки
      canvas.drawLine(
        Offset((startX + 8).toDouble(), (startY - 8).toDouble()),
        Offset(startX.toDouble(), startY.toDouble()),
        paint,
      );
      canvas.drawLine(
        Offset((startX + length - 8).toDouble(), (startY - 8).toDouble()),
        Offset((startX + length).toDouble(), startY.toDouble()),
        paint,
      );
    }

    // Текст размера
    final labelPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF8B2346),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();

    if (vertical) {
      labelPainter.paint(
        canvas,
        Offset((startX - 60).toDouble(), (startY + length / 2 - 8).toDouble()),
      );
    } else {
      labelPainter.paint(
        canvas,
        Offset((startX + length / 2 - 20).toDouble(), (startY - 30).toDouble()),
      );
    }
  }

  static void _drawOptions(
    ui.Canvas canvas,
    int yPos,
    bool isHandFold,
    bool isTape,
    String techComment,
  ) {
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: 'СПЕЦИАЛЬНЫЕ ТРЕБОВАНИЯ',
        style: TextStyle(
          color: Color(0xFF8B2346),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, Offset(40, yPos.toDouble()));

    int currentY = yPos + 30;

    if (isHandFold) {
      final handFoldPainter = TextPainter(
        text: const TextSpan(
          text: '✓ Ручная складка',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        textDirection: TextDirection.ltr,
      );
      handFoldPainter.layout();
      handFoldPainter.paint(canvas, Offset(60, currentY.toDouble()));
      currentY += 25;
    }

    if (isTape) {
      final tapePainter = TextPainter(
        text: const TextSpan(
          text: '✓ Шторная лента',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        textDirection: TextDirection.ltr,
      );
      tapePainter.layout();
      tapePainter.paint(canvas, Offset(60, currentY.toDouble()));
      currentY += 25;
    }

    if (techComment.isNotEmpty) {
      final commentPainter = TextPainter(
        text: TextSpan(
          text: 'Примечание: $techComment',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
      );
      commentPainter.layout();
      commentPainter.paint(canvas, Offset(60, currentY.toDouble()));
    }
  }

  static void _drawFooter(ui.Canvas canvas, int yPos) {
    // Линия
    canvas.drawLine(
      const Offset(40, 1700),
      const Offset(1200, 1700),
      Paint()
        ..color = Colors.grey[300]!
        ..strokeWidth = 1,
    );

    final addressPainter = TextPainter(
      text: const TextSpan(
        text: companyAddress,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
      textDirection: TextDirection.ltr,
    );
    addressPainter.layout();
    addressPainter.paint(canvas, const Offset(40, 1710));

    final contactPainter = TextPainter(
      text: const TextSpan(
        text: 'Тел: $companyPhone | Email: $companyEmail',
        style: TextStyle(fontSize: 11, color: Color(0xFF8B2346)),
      ),
      textDirection: TextDirection.ltr,
    );
    contactPainter.layout();
    contactPainter.paint(canvas, const Offset(40, 1730));
  }
}