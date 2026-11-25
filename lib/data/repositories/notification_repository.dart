

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/notification.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('notifications');

  // Foydalanuvchining bildirishnomalarini olish
  Stream<List<AppNotification>> getMyNotifications() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Avval tizimga kiring.');
    }

    return _collection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppNotification.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  // Bildirishnoma yaratish
  Future<void> addNotification({
    required String userId,
    required String title,
    required String message,
    required String complaintId,
  }) async {
    await _collection.add({
      'userId': userId,
      'title': title,
      'message': message,
      'complaintId': complaintId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Bildirishnomani o'qilgan deb belgilash
  Future<void> markAsRead(String notificationId) async {
    await _collection.doc(notificationId).update({
      'isRead': true,
    });
  }
}
