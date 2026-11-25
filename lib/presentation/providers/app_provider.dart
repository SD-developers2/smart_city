
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/complaint.dart';
import '../../data/repositories/complaint_repository.dart';

class AppProvider extends ChangeNotifier {
  final ComplaintRepository _repository = ComplaintRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<List<Complaint>>? _complaintSubscription;
  StreamSubscription<List<Complaint>>? _myComplaintsSubscription;
  StreamSubscription<User?>? _authSubscription;

  int _authChangeVersion = 0;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  List<Complaint> _complaints = [];
  List<Complaint> get complaints => List.unmodifiable(_complaints);

  List<Complaint> _myComplaints = [];
  List<Complaint> get myComplaints =>
      List.unmodifiable(_myComplaints);

  // Admin barcha murojaatlarni, foydalanuvchi esa o'zinikini ko'radi.
  List<Complaint> get visibleComplaints =>
      _isAdmin ? _complaints : _myComplaints;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isMyComplaintsLoading = false;
  bool get isMyComplaintsLoading => _isMyComplaintsLoading;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  bool _isAdminLoading = true;
  bool get isAdminLoading => _isAdminLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _myComplaintsError;
  String? get myComplaintsError => _myComplaintsError;

  // Statistika barcha foydalanuvchilar uchun to'g'ri hisoblanadi.
  int get totalComplaints => visibleComplaints.length;

  int get newComplaints =>
      visibleComplaints.where((e) => e.status == 'Yangi').length;

  int get pendingComplaints =>
      visibleComplaints.where((e) => e.status == 'Jarayonda').length;

  int get completedComplaints =>
      visibleComplaints.where((e) => e.status == 'Yakunlangan').length;

  AppProvider() {
    _authSubscription = _auth.authStateChanges().listen(
      _handleAuthChange,
    );
  }

  // Foydalanuvchi holati o'zgarganda barcha oqimlarni qayta ulash.
  Future<void> _handleAuthChange(User? user) async {
    final version = ++_authChangeVersion;

    await _cancelSubscriptions();

    // Agar shu vaqt ichida yangi auth hodisasi kelgan bo'lsa,
    // eski hodisa davom etmasin.
    if (version != _authChangeVersion) return;

    _complaints = [];
    _myComplaints = [];

    _errorMessage = null;
    _myComplaintsError = null;

    _isAdmin = false;
    _selectedIndex = 0;

    _isLoading = user != null;
    _isMyComplaintsLoading = user != null;
    _isAdminLoading = user != null;

    if (user == null) {
      _isLoading = false;
      _isMyComplaintsLoading = false;
      _isAdminLoading = false;
      notifyListeners();
      return;
    }

    notifyListeners();

    try {
      final adminStatus = await checkAdminStatus();

      if (version != _authChangeVersion) return;

      _isAdmin = adminStatus;

      if (_isAdmin) {
        _listenToComplaints();
      } else {
        _isLoading = false;
      }
    } catch (error) {
      if (version != _authChangeVersion) return;

      _isAdmin = false;
      _isLoading = false;
      _errorMessage = error.toString();
    }

    if (version != _authChangeVersion) return;

    _listenToMyComplaints();

    _isAdminLoading = false;
    notifyListeners();
  }

  Future<void> _cancelSubscriptions() async {
    await _complaintSubscription?.cancel();
    await _myComplaintsSubscription?.cancel();

    _complaintSubscription = null;
    _myComplaintsSubscription = null;
  }

  // Administrator huquqini tekshirish.
  Future<bool> checkAdminStatus() async {
    final user = _auth.currentUser;

    if (user == null) return false;

    final doc = await _firestore
        .collection('admins')
        .doc(user.uid)
        .get();

    return doc.exists && doc.data()?['enabled'] == true;
  }

  // Admin uchun barcha murojaatlarni kuzatish.
  void _listenToComplaints() {
    _complaintSubscription = _repository.getComplaints().listen(
      (data) {
        _complaints = data;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // Oddiy foydalanuvchi uchun faqat o'z murojaatlarini kuzatish.
  void _listenToMyComplaints() {
    _myComplaintsSubscription =
        _repository.getMyComplaints().listen(
      (data) {
        _myComplaints = data;
        _isMyComplaintsLoading = false;
        _myComplaintsError = null;
        notifyListeners();
      },
      onError: (error) {
        _isMyComplaintsLoading = false;
        _myComplaintsError = error.toString();
        notifyListeners();
      },
    );
  }

  // Navigatsiya bo'limini almashtirish.
  void changeTab(int index) {
    final maxIndex = _isAdmin ? 5 : 4;

    if (index < 0 || index > maxIndex) return;

    _selectedIndex = index;
    notifyListeners();
  }

  // Yangi murojaat qo'shish.
  Future<void> addComplaint({
    required String title,
    required String category,
    required String address,
    required String description,
    double? latitude,
    double? longitude,
  }) async {
    _errorMessage = null;
    notifyListeners();

    final complaint = Complaint(
      id: 'SC-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      category: category,
      address: address,
      description: description,
      status: 'Yangi',
      createdAt: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
    );

    try {
      await _repository.addComplaint(complaint);
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Faqat administrator murojaat holatini o'zgartiradi.
  Future<void> updateComplaintStatus({
    required String complaintId,
    required String newStatus,
  }) async {
    const allowedStatuses = [
      'Yangi',
      'Jarayonda',
      'Yakunlangan',
    ];

    if (!_isAdmin) {
      throw Exception(
        'Murojaat holatini faqat administrator o‘zgartira oladi.',
      );
    }

    if (!allowedStatuses.contains(newStatus)) {
      throw Exception('Noto‘g‘ri murojaat holati.');
    }

    await _repository.updateComplaintStatus(
      complaintId: complaintId,
      newStatus: newStatus,
    );
  }

  @override
  void dispose() {
    _authChangeVersion++;

    _complaintSubscription?.cancel();
    _myComplaintsSubscription?.cancel();
    _authSubscription?.cancel();

    super.dispose();
  }
}
