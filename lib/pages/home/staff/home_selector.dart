import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_credit/services/auth_service.dart';

class HomeSelectorPage extends StatefulWidget {
  final String userRole;
  const HomeSelectorPage({super.key, required this.userRole});

  bool get isAdmin => userRole == 'admin';

  @override
  State<HomeSelectorPage> createState() => _HomeStaffPageState();
}

class _HomeStaffPageState extends State<HomeSelectorPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _redirecting = true; // thêm để tránh UI staff hiện ra trước khi redirect

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoRedirect());
  }

  void _autoRedirect() {
    final role = widget.userRole.toLowerCase().trim();

    if (role == "customers" || role == "customer" || role == "user") {
      Navigator.pushReplacementNamed(context, "/customerHome");
      return;
    }

    if (role == "admin") {
      Navigator.pushReplacementNamed(context, "/adminHome");
      return;
    }

    Navigator.pushReplacementNamed(context, "/staffHome");
  }

  Future<void> _signOut() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  // Xoá hợp đồng
  Future<void> _deleteLoan(String loanId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa hợp đồng này? Toàn bộ bản ghi thanh toán sẽ bị xóa.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Xóa')),
        ],
      ),
    );

    if (confirm != true) return;

    final batch = _firestore.batch();
    final loanRef = _firestore.collection('loans').doc(loanId);

    final repayments = await loanRef.collection('repayments').get();
    for (final doc in repayments.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(loanRef);

    await batch.commit();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa hợp đồng.')));
  }

  void _openUpdateRepayment(String loanId) {
    Navigator.pushNamed(context, '/updateRepayment', arguments: {'loanId': loanId});
  }

  void _openManageStaff() {
    Navigator.pushNamed(context, '/staffManagement');
  }

  void _openCreateContract() {
    Navigator.pushNamed(context, '/loanContract');
  }

  void _openLoanList() {
    Navigator.pushNamed(context, '/loanList');
  }

  Widget _statCard(String label, Stream<int> stream, IconData icon) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snap) {
        final value = snap.data ?? 0;
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  child: Icon(icon, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 8),
                    Text(value.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Stream<int> get _totalLoansStream =>
      _firestore.collection('loans').snapshots().map((s) => s.docs.length);

  Stream<int> get _pendingLoansStream => _firestore
      .collection('loans')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((s) => s.docs.length);

  Stream<int> get _rejectedLoansStream => _firestore
      .collection('loans')
      .where('status', isEqualTo: 'rejected')
      .snapshots()
      .map((s) => s.docs.length);

  Widget _recentLoans() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('loans').orderBy('createdAt', descending: true).limit(5).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return const Text('Không có hợp đồng nào gần đây.');

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = data['amount'] ?? 0;
            final status = data['status'] ?? '';
            final customerId = data['customerId'] ?? '';
            final createdAt = data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate() : null;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text('Khách: $customerId'),
                subtitle: Text('Số tiền: ${amount.toString()} · Trạng thái: $status${createdAt != null ? ' · ' + createdAt.toString() : ''}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'update') _openUpdateRepayment(doc.id);
                    if (v == 'delete' && widget.isAdmin) _deleteLoan(doc.id);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'update', child: Text('Cập nhật thanh toán')),
                    if (widget.isAdmin) const PopupMenuItem(value: 'delete', child: Text('Xóa hợp đồng')),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/loanDetail', arguments: {'loanId': doc.id});
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_redirecting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Giữ nguyên toàn bộ UI cũ của anh
    final title = widget.isAdmin ? 'Trang quản trị (Admin)' : 'Trang nhân viên';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF1976D2),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        ),
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(child: _statCard('Tổng hợp đồng', _totalLoansStream, Icons.receipt_long)),
                  const SizedBox(width: 8),
                  Expanded(child: _statCard('Chờ duyệt', _pendingLoansStream, Icons.hourglass_top)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _statCard('Bị từ chối', _rejectedLoansStream, Icons.cancel)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: _openLoanList,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: const [
                              CircleAvatar(radius: 26, child: Icon(Icons.list)),
                              SizedBox(width: 16),
                              Text('Danh sách khoản vay', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: const Text('Tạo hợp đồng', style: TextStyle(fontSize: 18)),
                  trailing: const Icon(Icons.add),
                  onTap: _openCreateContract,
                ),
              ),

              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: const Text('Cập nhật thanh toán', style: TextStyle(fontSize: 18)),
                  trailing: const Icon(Icons.payment),
                  onTap: () => Navigator.pushNamed(context, '/repaymentList'),
                ),
              ),

              if (widget.isAdmin)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: const Text('Quản lý nhân viên', style: TextStyle(fontSize: 18)),
                    trailing: const Icon(Icons.manage_accounts),
                    onTap: _openManageStaff,
                  ),
                ),

              if (widget.isAdmin)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: const Text('Xóa hợp đồng (Tìm theo ID)', style: TextStyle(fontSize: 18)),
                    subtitle: const Text('Dùng để xóa nhanh bằng ID hợp đồng'),
                    trailing: const Icon(Icons.delete_forever),
                    onTap: () async {
                      final id = await showDialog<String>(
                        context: context,
                        builder: (c) {
                          final ctrl = TextEditingController();
                          return AlertDialog(
                            title: const Text('Xóa hợp đồng theo ID'),
                            content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Loan ID')),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c), child: const Text('Hủy')),
                              ElevatedButton(onPressed: () => Navigator.pop(c, ctrl.text.trim()), child: const Text('Xóa')),
                            ],
                          );
                        },
                      );
                      if (id != null && id.isNotEmpty) {
                        await _deleteLoan(id);
                      }
                    },
                  ),
                ),

              const SizedBox(height: 20),
              const Text('Hợp đồng gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _recentLoans(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
