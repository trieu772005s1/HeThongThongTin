// lib/pages/home/staff/home_staff_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_credit/services/auth_service.dart';

class HomeStaffPage extends StatelessWidget {
  final String userRole;

  const HomeStaffPage({super.key, required this.userRole});

  bool get isAdmin => userRole == 'admin';

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom + 16;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FF),
      appBar: _buildHeader(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double actionAspect = constraints.maxWidth > 420
                ? 1.06
                : 0.98;

            return ListView(
              padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
              children: [
                // ===== STAT CARDS =====
                LayoutBuilder(
                  builder: (context, box) {
                    const spacing = 12.0;
                    final width = box.maxWidth;
                    int cols = width < 420 ? 1 : (width < 700 ? 2 : 3);
                    final itemW = (width - spacing * (cols - 1)) / cols;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: itemW,
                          child: _statCardStream(
                            title: 'Tổng hợp hợp đồng',
                            icon: Icons.receipt_long,
                            query: FirebaseFirestore.instance.collection(
                              'loans',
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/loanList');
                            },
                          ),
                        ),
                        SizedBox(
                          width: itemW,
                          child: _statCardStream(
                            title: 'Chờ duyệt',
                            icon: Icons.hourglass_top,
                            query: FirebaseFirestore.instance
                                .collection('loans')
                                .where('status', isEqualTo: 'pending'),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/loanList',
                                arguments: {'status': 'pending'},
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: itemW,
                          child: _statCardStream(
                            title: 'Bị từ chối',
                            icon: Icons.cancel,
                            query: FirebaseFirestore.instance
                                .collection('loans')
                                .where('status', isEqualTo: 'rejected'),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/loanList',
                                arguments: {'status': 'rejected'},
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 18),
                _sectionTitle('Chức năng chính'),
                const SizedBox(height: 10),

                // ===== ACTION GRID =====
                GridView.count(
                  crossAxisCount: constraints.maxWidth > 500 ? 3 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: actionAspect,
                  children: [
                    _actionCard(
                      context,
                      'Tạo hợp đồng',
                      'Thêm hợp đồng mới',
                      Icons.add_box,
                      onTap: () =>
                          Navigator.pushNamed(context, '/loanContract'),
                    ),
                    _actionCard(
                      context,
                      'Danh sách khoản vay',
                      'Quản lý & tìm kiếm',
                      Icons.list_alt,
                      onTap: () => Navigator.pushNamed(context, '/loanList'),
                    ),
                    _actionCard(
                      context,
                      'Cập nhật thanh toán',
                      'Ghi nhận / chỉnh sửa',
                      Icons.payment,
                      onTap: () =>
                          Navigator.pushNamed(context, '/repaymentList'),
                    ),
                    _actionCard(
                      context,
                      'Thông báo',
                      'Xem thông báo',
                      Icons.notifications,
                      onTap: () =>
                          Navigator.pushNamed(context, '/notifications'),
                    ),
                    if (isAdmin)
                      _actionCard(
                        context,
                        'Quản lý nhân viên',
                        'Thêm / sửa / xóa',
                        Icons.manage_accounts,
                        onTap: () =>
                            Navigator.pushNamed(context, '/staffManagement'),
                      ),
                  ],
                ),

                const SizedBox(height: 20),
                _sectionTitle('Hợp đồng gần đây'),
                const SizedBox(height: 12),

                // ===== RECENT LOANS =====
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('loans')
                      .orderBy('createdAt', descending: true)
                      .limit(6)
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snap.data!.docs;
                    if (docs.isEmpty) {
                      return const Text('Chưa có hợp đồng nào');
                    }

                    // Build a column of loan tiles; for each loan we fetch the user doc (if customerId present)
                    return Column(
                      children: docs.map((d) {
                        final data = d.data() as Map<String, dynamic>;
                        final customerId = (data['customerId'] ?? '')
                            .toString();
                        final amount = data['amount'] ?? '';

                        if (customerId.isEmpty) {
                          // fallback when no customerId
                          return _loanTile(
                            context,
                            loanId: d.id,
                            customerLabel: 'KH: -',
                            amountLabel: 'Số tiền: $amount',
                          );
                        }

                        // FutureBuilder fetches the user doc to show name
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(customerId)
                              .get(),
                          builder: (ctx, userSnap) {
                            String customerLabel =
                                'KH: ${_shorten(customerId)}';
                            if (userSnap.connectionState ==
                                    ConnectionState.done &&
                                userSnap.hasData &&
                                userSnap.data!.exists) {
                              final u =
                                  (userSnap.data!.data() ?? {})
                                      as Map<String, dynamic>;
                              final name =
                                  (u['full_name'] ??
                                          u['fullName'] ??
                                          u['name'] ??
                                          '')
                                      .toString();
                              if (name.isNotEmpty) customerLabel = 'KH: $name';
                            }
                            return _loanTile(
                              context,
                              loanId: d.id,
                              customerLabel: customerLabel,
                              amountLabel: 'Số tiền: $amount',
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ================= COMPONENTS =================

  PreferredSizeWidget _buildHeader(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(96),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.fromLTRB(16, 20, 12, 16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF1976D2)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isAdmin
                      ? 'Bảng điều khiển Admin'
                      : 'Bảng điều khiển Nhân viên',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await AuthService().signOut();
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loanTile(
    BuildContext context, {
    required String loanId,
    required String customerLabel,
    required String amountLabel,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.receipt_long, color: Colors.blue),
        ),
        title: Text(
          customerLabel,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(amountLabel),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/loanDetail',
            arguments: {'loanId': loanId},
          );
        },
      ),
    );
  }

  Widget _statCardStream({
    required String title,
    required IconData icon,
    required Query query,
    required VoidCallback onTap,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snap) {
        final count = snap.data?.docs.length ?? 0;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: Colors.indigo),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );

  static String _shorten(String s, {int keep = 8}) =>
      s.length <= keep ? s : '${s.substring(0, keep)}...';

  Widget _actionCard(
    BuildContext context,
    String title,
    String sub,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.indigo),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              sub,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
