import 'package:excel/excel.dart' as ex;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../features/clients/domain/entities/client.dart';

class ExcelExporter {
  static Future<void> exportForClient(BuildContext context, List<Client> clients) async {
    try {
      var excel = ex.Excel.createExcel();
      var sheet = excel['Отчет для клиента'];

      // Заголовок
      sheet.appendRow(['МАРТ ПРО 8', '', '', '', '']);
      sheet.appendRow(['Отчет для клиента', '', '', '', '']);
      sheet.appendRow(['Дата: ${DateTime.now().toString().split('.')[0]}', '', '', '', '']);
      sheet.appendRow(['', '', '', '', '']);

      // Таблица
      sheet.appendRow(['Клиент', 'Телефон', 'Комната', 'Статус', 'Итого (₽)']);

      for (var client in clients) {
        for (var room in client.rooms) {
          sheet.appendRow([
            client.name,
            client.phone,
            room.name,
            client.status == 'work' ? 'В работе' : 'Закрыт',
            room.clientPrice.toStringAsFixed(0),
          ]);
        }
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'МАРТ_ПРО8_Клиент_${DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '')}.xlsx';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(excel.encode()!);
      await Share.shareXFiles([XFile(file.path)], text: 'Отчет для клиента');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Excel (клиент): $fileName'), duration: const Duration(seconds: 5)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }

  static Future<void> exportFull(BuildContext context, List<Client> clients) async {
    try {
      var excel = ex.Excel.createExcel();
      var sheet = excel['Полный отчет'];

      // Заголовок
      sheet.appendRow(['МАРТ ПРО 8 - ПОЛНЫЙ ОТЧЕТ', '', '', '', '', '', '', '', '']);
      sheet.appendRow(['Дата: ${DateTime.now().toString().split('.')[0]}', '', '', '', '', '', '', '', '']);
      sheet.appendRow(['', '', '', '', '', '', '', '', '']);

      // Таблица
      sheet.appendRow([
        'Клиент',
        'Телефон',
        'Комната',
        'Статус',
        'Ткань (м)',
        'Стоимость ткани (₽)',
        'Пошив швеи (₽)',
        'Цена клиента (₽)',
        'Себестоимость (₽)',
        'ДОХОД (₽)',
      ]);

      double totalIncome = 0;
      double totalCost = 0;
      double totalProfit = 0;

      for (var client in clients) {
        for (var room in client.rooms) {
          sheet.appendRow([
            client.name,
            client.phone,
            room.name,
            client.status == 'work' ? 'В работе' : 'Закрыт',
            room.fabricMeters.toStringAsFixed(2),
            room.fabricCost.toStringAsFixed(0),
            room.sewingCostSeamstress.toStringAsFixed(0),
            room.clientPrice.toStringAsFixed(0),
            room.totalCost.toStringAsFixed(0),
            room.profit.toStringAsFixed(0),
          ]);

          totalIncome += room.clientPrice;
          totalCost += room.totalCost;
          totalProfit += room.profit;
        }
      }

      // ИТОГО
      sheet.appendRow(['', '', '', '', '', '', '', '', '', '']);
      sheet.appendRow(['ИТОГО:', '', '', '', '', '', '', totalIncome.toStringAsFixed(0), totalCost.toStringAsFixed(0), totalProfit.toStringAsFixed(0)]);

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'МАРТ_ПРО8_Полный_${DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '')}.xlsx';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(excel.encode()!);
      await Share.shareXFiles([XFile(file.path)], text: 'Полный отчет МАРТ ПРО 8');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Excel (полный): $fileName'), duration: const Duration(seconds: 5)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }

  static Future<void> exportIncome(BuildContext context, List<Client> clients) async {
    try {
      var excel = ex.Excel.createExcel();
      var sheet = excel['Мой доход'];

      // Заголовок
      sheet.appendRow(['МАРТ ПРО 8 - МОЙ ДОХОД', '', '', '', '']);
      sheet.appendRow(['Дата отчета: ${DateTime.now().toString().split('.')[0]}', '', '', '', '']);
      sheet.appendRow(['', '', '', '', '']);

      // Таблица - только ЗАКРЫТЫЕ заказы
      sheet.appendRow(['Клиент', 'Комната', 'Цена клиента (₽)', 'Себестоимость (₽)', 'МОЙ ДОХОД (₽)']);

      double completedIncome = 0;

      for (var client in clients) {
        if (client.status == 'done') {
          for (var room in client.rooms) {
            sheet.appendRow([
              client.name,
              room.name,
              room.clientPrice.toStringAsFixed(0),
              room.totalCost.toStringAsFixed(0),
              room.profit.toStringAsFixed(0),
            ]);
            completedIncome += room.profit;
          }
        }
      }

      // ИТОГО
      sheet.appendRow(['', '', '', '', '']);
      sheet.appendRow(['ВСЕГО ДОХОД (закрытые заказы):', '', '', '', completedIncome.toStringAsFixed(0)]);

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'МАРТ_ПРО8_Доход_${DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '')}.xlsx';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(excel.encode()!);
      await Share.shareXFiles([XFile(file.path)], text: 'Отчет о доходе');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Excel (доход): $fileName'), duration: const Duration(seconds: 5)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }
}