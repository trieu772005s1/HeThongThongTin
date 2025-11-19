// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================
  //        USER PROFILE
  // ============================

  // Tạo hồ sơ user sau khi đăng ký
  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String email,
    required String phone,
    String role = 'customer', // mặc định khách hàng
  }) async {
    await _db.collection('users').doc(uid).set({
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Lấy hồ sơ user 1 lần
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  // Lấy hồ sơ user realtime
  Stream<DocumentSnapshot<Map<String, dynamic>>> userProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // ============================
  //        LOAN CONTRACTS
  // ============================

  // Tạo hợp đồng vay mới
  Future<String> createLoan({
    required String customerId, // uid khách hàng
    required double amount, // số tiền vay
    required double interestRate, // lãi suất %/năm
    required int termMonths, // số tháng vay
    required DateTime startDate, // ngày bắt đầu
    String status = 'pending', // trạng thái mặc định
  }) async {
    final docRef = await _db.collection('loans').add({
      'customerId': customerId,
      'amount': amount,
      'interestRate': interestRate,
      'termMonths': termMonths,
      'startDate': Timestamp.fromDate(startDate),
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id; // trả về id hợp đồng
  }

  // Danh sách hợp đồng của 1 khách (realtime)
  Stream<QuerySnapshot<Map<String, dynamic>>> loansByCustomerStream(
    String customerId,
  ) {
    return _db
        .collection('loans')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Lấy chi tiết 1 hợp đồng
  Future<DocumentSnapshot<Map<String, dynamic>>> getLoan(String loanId) {
    return _db.collection('loans').doc(loanId).get();
  }

  // Cập nhật trạng thái hợp đồng
  Future<void> updateLoanStatus({
    required String loanId,
    required String status,
  }) {
    return _db.collection('loans').doc(loanId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Xoá hợp đồng
  Future<void> deleteLoan(String loanId) {
    return _db.collection('loans').doc(loanId).delete();
  }

  // Danh sách TẤT CẢ hợp đồng (staff/admin dùng)
  Stream<QuerySnapshot<Map<String, dynamic>>> allLoansStream() {
    return _db
        .collection('loans')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
