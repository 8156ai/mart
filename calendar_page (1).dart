import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../domain/entities/client.dart';
import '../providers/client_provider.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientNotifierProvider);

    // ✅ Собрать все сделки со сроками
    final allDeals = <Map<String, dynamic>>[];
    for (var client in clients) {
      for (var room in client.rooms) {
        if (room.clientDeadline != null) {
          allDeals.add({
            'clientName': client.name,
            'roomName': room.name,
            'deadline': room.clientDeadline,
            'type': 'client',
            'status': client.status,
            'isOverdue': room.clientDeadline!.isBefore(DateTime.now()),
          });
        }
        if (room.seamstressDeadline != null) {
          allDeals.add({
            'clientName': client.name,
            'roomName': room.name,
            'deadline': room.seamstressDeadline,
            'type': 'seamstress',
            'status': client.status,
            'isOverdue': room.seamstressDeadline!.isBefore(DateTime.now()),
          });
        }
      }
    }

    // ✅ Отфильтровать для выбранного дня
    final dealsForDay = allDeals
        .where((deal) =>
            deal['deadline'].year == _selectedDay.year &&
            deal['deadline'].month == _selectedDay.month &&
            deal['deadline'].day == _selectedDay.day)
        .toList();

    // ✅ Отфильтровать по статусам для календаря
    final dealsByDate = <DateTime, List<Map<String, dynamic>>>{};
    for (var deal in allDeals) {
      final date = DateTime(
        deal['deadline'].year,
        deal['deadline'].month,
        deal['deadline'].day,
      );
      dealsByDate.putIfAbsent(date, () => []);
      dealsByDate[date]!.add(deal);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 КАЛЕНДАРЬ СДЕЛОК'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ✅ КАЛЕНДАРЬ
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue.shade200,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF8B2346),
                shape: BoxShape.circle,
              ),
              defaultTextStyle: const TextStyle(fontSize: 14),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            eventLoader: (day) {
              final date = DateTime(day.year, day.month, day.day);
              return dealsByDate[date] ?? [];
            },
          ),
          const SizedBox(height: 16),
          // ✅ СДЕЛКИ НА ВЫБРАННЫЙ ДЕНЬ
          Expanded(
            child: dealsForDay.isEmpty
                ? Center(
                    child: Text(
                      '${_selectedDay.day}.${_selectedDay.month}.${_selectedDay.year}\nНет сделок',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dealsForDay.length,
                    itemBuilder: (context, index) {
                      final deal = dealsForDay[index];
                      final isOverdue = deal['isOverdue'] as bool;
                      final status = deal['status'] as String;
                      final deadline = deal['deadline'] as DateTime;

                      Color statusColor;
                      String statusText;

                      if (isOverdue && status == 'work') {
                        statusColor = Colors.red;
                        statusText = 'СРОК ИСТЕК';
                      } else if (status == 'work') {
                        statusColor = Colors.orange;
                        statusText = 'В РАБОТЕ';
                      } else {
                        statusColor = Colors.green;
                        statusText = 'ЗАКРЫТО';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        deal['clientName'],
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        deal['roomName'],
                                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${deal['type'] == 'client' ? '👤 Срок клиента' : '👩‍🔧 Срок швеи'}: ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 13, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}