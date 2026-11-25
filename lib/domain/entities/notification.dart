import 'package:cloud_firestore/cloud_firestore.dart';
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String complaintId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.complaintId,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    final timestamp = data['createdAt'];

    return AppNotification(
      id: id,
      userId: data['userId']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      complaintId: data['complaintId']?.toString() ?? '',
      isRead: data['isRead'] == true,
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.now(),
    );
  }
}
