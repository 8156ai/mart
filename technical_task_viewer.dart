import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../../domain/entities/room.dart';

class TechnicalTaskViewer extends StatefulWidget {
  final String clientName;
  final String roomName;
  final Room room;

  const TechnicalTaskViewer({
    super.key,
    required this.clientName,
    required this.roomName,
    required this.room,
  });

  @override
  State<TechnicalTaskViewer> createState() => _TechnicalTaskViewerState();
}

class _TechnicalTaskViewerState extends State<TechnicalTaskViewer> {
  late Future<Uint8List> _tzImageFuture;

  @override
  void initState() {
    super.initState();
    _tzImageFuture = _generateTZImage();
  }

  Future<Uint8List> _generateTZImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const ui.Size(1400, 1800);

    // Белый фон
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // Заголовок
    _drawTZHeader(canvas, size);

    double y = 160;

    // Информация о заказе
    final specs = widget.room.technicalSpecs;
    final orderNumber = '${widget.roomName}_${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}';
    
    _drawText(canvas, 'Заказ №$orderNumber', 80, y, fontSize: 22, fontWeight: FontWeight.bold);
    _drawText(canvas, 'Клиент: ${widget.clientName}', 80, y + 35, fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346));
    _drawText(canvas, 'Комната: ${widget.roomName}', 80, y + 60, fontSize: 14, color: Colors.grey);

    y += 150;

    // Таблица параметров
    y = _drawParametersTable(canvas, y.toInt(), specs).toDouble();

    y += 40;

    // Схема раскроя
    y = _drawCuttingSketch(
      canvas,
      y.toInt(),
      specs['cornice'] ?? 0,
      specs['height'] ?? 0,
      specs['topHem'] ?? 0,
      specs['bottomHem'] ?? 0,
    ).toDouble();

    y += 40;

    // Нижняя часть
    _drawTZFooter(canvas, size, y.toInt());

    // Конвертируем в изображение
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  void _drawTZHeader(Canvas canvas, ui.Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 120),
      Paint()..color = const Color(0xFFF5F5F5),
    );

    // Логотип
    canvas.drawCircle(
      const Offset(80, 60),
      35,
      Paint()
        ..color = Colors.transparent
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF8B2346),
    );

    _drawText(canvas, 'М', 80, 60, fontSize: 40, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346), align: TextAlign.center);

    _drawText(canvas, 'ТЕХНИЧЕСКОЕ ЗАДАНИЕ', 200, 40, fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346));
    _drawText(canvas, 'Студия текстильного дизайна МАРТ', 200, 75, fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic);
  }

  int _drawParametersTable(Canvas canvas, int yPos, Map<String, dynamic> specs) {
    _drawText(canvas, 'ПАРАМЕТРЫ ИЗДЕЛИЯ', 80, yPos.toDouble(), fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346));

    yPos += 35;

    final data = [
      ['Ширина карниза', '${specs['cornice']?.toStringAsFixed(0) ?? '0'} см'],
      ['Выс��та', '${specs['height']?.toStringAsFixed(0) ?? '0'} см'],
      ['Коэффициент сборки', '${specs['coef']?.toStringAsFixed(1) ?? '2'}x'],
      ['Подгибы (верх/низ)', '${specs['topHem']?.toStringAsFixed(0) ?? '0'} / ${specs['bottomHem']?.toStringAsFixed(0) ?? '0'} см'],
      ['Подгибы (слева/справа)', '${specs['leftHem']?.toStringAsFixed(0) ?? '0'} / ${specs['rightHem']?.toStringAsFixed(0) ?? '0'} см'],
      ['Полотен', '${specs['panels']?.toStringAsFixed(0) ?? '2'} шт'],
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
        Rect.fromLTWH((80 + col1Width).toDouble(), yPos.toDouble(), col2Width.toDouble(), rowHeight.toDouble()),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH((80 + col1Width).toDouble(), yPos.toDouble(), col2Width.toDouble(), rowHeight.toDouble()),
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke,
      );

      _drawText(canvas, row[1], (100 + col1Width).toDouble(), (yPos + 17).toDouble(), fontSize: 13, fontWeight: FontWeight.bold);

      yPos += rowHeight;
    }

    return yPos;
  }

  int _drawCuttingSketch(Canvas canvas, int yPos, double cornice, double height, double topHem, double bottomHem) {
    _drawText(canvas, 'СХЕМА РАСКРОЯ', 80, yPos.toDouble(), fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346));

    yPos += 40;

    const int rectX = 400;
    const int rectW = 200;
    const int rectH = 300;

    canvas.drawRect(
      Rect.fromLTWH(rectX.toDouble(), yPos.toDouble(), rectW.toDouble(), rectH.toDouble()),
      Paint()
        ..color = Colors.transparent
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF8B2346),
    );

    _drawText(canvas, '${cornice.toStringAsFixed(0)} см', (rectX + rectW / 2).toDouble(), (yPos - 30).toDouble(), fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346), align: TextAlign.center);
    _drawText(canvas, '${height.toStringAsFixed(0)} см', (rectX - 60).toDouble(), (yPos + rectH / 2).toDouble(), fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF8B2346), align: TextAlign.center);

    _drawText(canvas, 'Верх ${topHem.toStringAsFixed(0)} см', (rectX + 50).toDouble(), (yPos + 20).toDouble(), fontSize: 12, color: Colors.grey);
    _drawText(canvas, 'Низ ${bottomHem.toStringAsFixed(0)} см', (rectX + 50).toDouble(), (yPos + rectH - 25).toDouble(), fontSize: 12, color: Colors.grey);

    return yPos + rectH + 40;
  }

  void _drawTZFooter(Canvas canvas, ui.Size size, int yPos) {
    canvas.drawLine(
      Offset(80, yPos.toDouble()),
      Offset(size.width - 80, yPos.toDouble()),
      Paint()
        ..color = Colors.grey.shade300
        ..strokeWidth = 1,
    );

    yPos += 20;

    _drawText(canvas, 'Лесной, ул. Пушкина 8Б, Пушкино', 80, yPos.toDouble(), fontSize: 11, color: Colors.grey);
    _drawText(canvas, 'Тел: +7 (977) 892-08-32 | Email: shtory.mart@yandex.ru', 80, (yPos + 20).toDouble(), fontSize: 11, color: const Color(0xFF8B2346));
    _drawText(canvas, 'Сайт: https://mart.see.ru', 80, (yPos + 40).toDouble(), fontSize: 11, color: const Color(0xFF8B2346));
  }

  void _drawText(
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

  @override
  Widget build(BuildContext context) {
    final specs = widget.room.technicalSpecs;

    return Scaffold(
      appBar: AppBar(
        title: Text('ТЗ: ${widget.roomName}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ РИСУНОК ТЗ С ЗУМОМ (ИСПРАВЛЕНО)
            Card(
              elevation: 4,
              child: FutureBuilder<Uint8List>(
                future: _tzImageFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    return Container(
                      color: Colors.grey.shade200,
                      constraints: const BoxConstraints(maxHeight: 600),
                      child: InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(100),
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.memory(
                          snapshot.data!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Ошибка при загрузке изображения'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // 📋 ИНФОРМАЦИЯ О КЛИЕНТЕ И КОМНАТЕ
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ИНФОРМАЦИЯ О ЗАКАЗЕ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue.shade700),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Клиент:', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(widget.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Комната:', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(widget.roomName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Тип штор:', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          _getCurtainTypeName(specs['curtainType'] ?? 'curtains'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 💰 ФИНАНСЫ
            Card(
              color: Colors.green.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ФИНАНСОВЫЕ ДАННЫЕ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green.shade700),
                    ),
                    const SizedBox(height: 12),
                    _buildFinanceRow('Цена клиента', '${widget.room.clientPrice.toStringAsFixed(0)} руб', Colors.green),
                    _buildFinanceRow('Себестоимость', '${widget.room.totalCost.toStringAsFixed(0)} руб', Colors.orange),
                    const Divider(thickness: 2),
                    _buildFinanceRow('Прибыль', '${(widget.room.clientPrice - widget.room.totalCost).toStringAsFixed(0)} руб', Colors.blue, bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📝 КОММЕНТАРИИ
            if (widget.room.comment.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('КОММЕНТАРИЙ КЛИЕНТА', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(widget.room.comment, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceRow(String label, String value, Color color, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w600, fontSize: bold ? 14 : 13),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: bold ? 15 : 13, color: color),
          ),
        ],
      ),
    );
  }

  String _getCurtainTypeName(String type) {
    const types = {
      'tulle': 'Тюль',
      'curtains': 'Портьеры',
      'curtains_lining': 'Портьеры на подкладе',
      'roman': 'Римские шторы',
      'roman_lining': 'Римские на подкладе',
    };
    return types[type] ?? type;
  }
}