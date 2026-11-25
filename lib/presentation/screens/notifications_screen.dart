
import 'package:flutter/material.dart';

import '../../data/repositories/notification_repository.dart';
import '../../domain/entities/notification.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = NotificationRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirishnomalar'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: repository.getMyNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Xatolik: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Hozircha bildirishnomalar yo‘q',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notification.isRead
                        ? Colors.grey.shade200
                        : Colors.green.shade100,
                    child: Icon(
                      Icons.notifications_active,
                      color: notification.isRead
                          ? Colors.grey
                          : Colors.green,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(notification.message),
                  ),
                  trailing: notification.isRead
                      ? const Icon(
                          Icons.done,
                          color: Colors.grey,
                        )
                      : const Icon(
                          Icons.circle,
                          color: Colors.green,
                          size: 10,
                        ),
                  onTap: () async {
                    if (!notification.isRead) {
                      try {
                        await repository.markAsRead(
                          notification.id,
                        );
                      } catch (error) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Xatolik yuz berdi: $error',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
