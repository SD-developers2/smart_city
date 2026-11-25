
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/complaint.dart';

class ComplaintRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('complaints');

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  Future<void> addComplaint(Complaint complaint) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Murojaat yuborish uchun tizimga kiring.');
    }

    await _collection.doc(complaint.id).set({
      'id': complaint.id,
      'userId': user.uid,
      'userEmail': user.email ?? '',
      'title': complaint.title,
      'category': complaint.category,
      'address': complaint.address,
      'description': complaint.description,
      'status': 'Yangi',
      'createdAt': FieldValue.serverTimestamp(),
      'latitude': complaint.latitude,
      'longitude': complaint.longitude,
    });
  }

  Stream<List<Complaint>> getComplaints() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(_fromFirestore).toList(),
        );
  }

  Stream<List<Complaint>> getMyComplaints() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Avval tizimga kiring.');
    }

    return _collection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(_fromFirestore).toList(),
        );
  }

  // Admin statusni o'zgartirganda bildirishnoma ham yaratiladi.
  Future<void> updateComplaintStatus({
    required String complaintId,
    required String newStatus,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Avval tizimga kiring.');
    }

    const allowedStatuses = [
      'Yangi',
      'Jarayonda',
      'Yakunlangan',
    ];

    if (!allowedStatuses.contains(newStatus)) {
      throw Exception('Noto‘g‘ri murojaat holati.');
    }

    final complaintRef = _collection.doc(complaintId);
    final complaintDoc = await complaintRef.get();

    if (!complaintDoc.exists) {
      throw Exception('Murojaat topilmadi.');
    }

    final complaintData = complaintDoc.data()!;
    final complaintUserId =
        complaintData['userId']?.toString() ?? '';

    if (complaintUserId.isEmpty) {
      throw Exception('Murojaat egasi aniqlanmadi.');
    }

    final notificationRef = _notifications.doc();

    final batch = _firestore.batch();

    batch.update(complaintRef, {
      'status': newStatus,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
      'statusUpdatedBy': user.uid,
    });

    batch.set(notificationRef, {
      'userId': complaintUserId,
      'title': 'Murojaat holati yangilandi',
      'message':
          'Murojaatingiz holati "$newStatus" holatiga o‘zgartirildi.',
      'complaintId': complaintId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Complaint _fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final timestamp = data['createdAt'];

    return Complaint(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      status: data['status']?.toString() ?? 'Yangi',
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.now(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }
}
