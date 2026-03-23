import 'package:flutter/material.dart';
import '../../features/clients/domain/entities/room.dart';

class TasksSidebar extends StatelessWidget {
  final List<MapEntry<String, Room>> upcomingTasks;
  final Function(String, Room) onTaskTap;

  const TasksSidebar({
    required this.upcomingTasks,
    required this.onTaskTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF8B2346),
            ),
            child: const Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '📅 ЗАПЛАНИРОВАННЫЕ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: upcomingTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 50,
                          color: Colors.green[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Нет запланированных\nзадач',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: upcomingTasks.length,
                    itemBuilder: (context, index) {
                      final entry = upcomingTasks[index];
                      final clientName = entry.key;
                      final room = entry.value;
                      final deadline = room.clientDeadline;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        elevation: 2,
                        child: ListTile(
                          onTap: () => onTaskTap(clientName, room),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B2346),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            room.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '👤 $clientName',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (deadline != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${deadline.day}.${deadline.month} ${deadline.hour}:${deadline.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
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