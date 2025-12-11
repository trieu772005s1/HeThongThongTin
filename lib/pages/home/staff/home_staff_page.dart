import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_credit/services/auth_service.dart';

class HomeStaffPage extends StatelessWidget {
  final String userRole;

  const HomeStaffPage({super.key, required this.userRole});

  bool get isAdmin => userRole == 'admin';

  @override
  Widget build(BuildContext context) {
    // colors
    const Color start = Color(0xFF1565C0);
    const Color end = Color(0xFF42A5F5);
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom + 16;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FF),
      // giảm chiều cao header để tiết kiệm không gian
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(88),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [start, end]),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            padding: const EdgeInsets.only(left: 16, right: 8, top: 14, bottom: 10),
            child: Row(
              children: [
                // avatar
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), shape: BoxShape.circle),
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: start),
                  ),
                ),
                const SizedBox(width: 12),
                // title & role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isAdmin ? 'Trang quản trị' : 'Trang nhân viên',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.shield, size: 12, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            'Quyền: ${isAdmin ? 'Admin' : 'Staff'}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // logout icon (small)
                IconButton(
                  onPressed: () async {
                    await AuthService().signOut();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  tooltip: 'Đăng xuất',
                )
              ],
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          // responsive values
          final double maxW = constraints.maxWidth;
          final double actionAspect = maxW > 420 ? 1.04 : 0.95;

          return ListView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
            children: [
              // --> RESPONSIVE STATS: Wrap with LayoutBuilder to avoid overflow
              LayoutBuilder(builder: (context, box) {
                const double spacing = 12;
                final double width = box.maxWidth;
                int cols = 3;
                if (width < 420) cols = 1;
                else if (width < 700) cols = 2;
                final double itemW = (width - spacing * (cols - 1)) / cols;

                return Wrap(
                  spacing: spacing,
                  runSpacing: 12,
                  children: [
                    SizedBox(width: itemW, child: _statCard('Tổng hợp\nhợp đồng', '125', Icons.receipt_long)),
                    SizedBox(width: itemW, child: _statCard('Chờ\nduyệt', '8', Icons.hourglass_top)),
                    SizedBox(width: itemW, child: _statCard('Bị từ\nchối', '3', Icons.cancel)),
                  ],
                );
              }),

              const SizedBox(height: 18),

              // Section title
              _sectionTitle('Chức năng chính'),
              const SizedBox(height: 10),

              // Grid actions responsive: 2 columns on phone, 3 on wider screen
              GridView.count(
                crossAxisCount: constraints.maxWidth > 500 ? 3 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: actionAspect,
                children: [
                  _actionCard(context, 'Tạo hợp đồng', 'Thêm hợp đồng mới', Icons.add_box,
                      onTap: () => Navigator.pushNamed(context, '/loanContract')),
                  _actionCard(context, 'Danh sách khoản vay', 'Quản lý & tìm kiếm', Icons.list_alt,
                      onTap: () => Navigator.pushNamed(context, '/loanList')),
                  _actionCard(context, 'Cập nhật thanh toán', 'Ghi nhận / chỉnh sửa', Icons.payment,
                      onTap: () => Navigator.pushNamed(context, '/repaymentList')),
                  _actionCard(context, 'Thông báo', 'Xem thông báo', Icons.notifications,
                      onTap: () => Navigator.pushNamed(context, '/notifications')),
                  if (isAdmin)
                    _actionCard(context, 'Quản lý nhân viên', 'Thêm / sửa / xóa', Icons.manage_accounts,
                        onTap: () => Navigator.pushNamed(context, '/staffManagement')),
                  if (isAdmin)
                    _actionCard(context, 'Xóa hợp đồng', 'Xóa nhanh theo ID', Icons.delete_forever,
                        color: Colors.redAccent, onTap: () => Navigator.pushNamed(context, '/loanList')),
                ],
              ),

              const SizedBox(height: 20),

              _sectionTitle('Hợp đồng gần đây'),
              const SizedBox(height: 12),

              // REALTIME RECENT LOANS (5 newest)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('loans')
                    .orderBy('createdAt', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Chưa có hợp đồng nào.', style: TextStyle(color: Colors.black54)),
                    );
                  }

                  return Column(
                    children: docs.map((d) {
                      final data = d.data() as Map<String, dynamic>? ?? {};
                      final customer = (data['customerId'] ?? '').toString();
                      final amount = data['amount']?.toString() ?? '-';
                      final status = data['status']?.toString() ?? '-';
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                          title: Text('Khách hàng: ${_shorten(customer)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('Số tiền: $amount  ·  Trạng thái: $status'),
                          trailing: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/loanDetail', arguments: {'loanId': d.id});
                            },
                            child: const Text('Chi tiết'),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),
              Center(child: Text('FL CREDIT • Phiên bản nội bộ', style: TextStyle(color: Colors.grey[600], fontSize: 12))),
            ],
          );
        }),
      ),
    );
  }

  // helper to shorten long ids/emails for display
  static String _shorten(String s, {int keep = 8}) {
    if (s.isEmpty) return s;
    if (s.length <= keep) return s;
    return '${s.substring(0, keep)}...';
  }

  // STAT CARD: ensure limited lines and consistent height
  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))
      ]),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.05),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
      ],
    );
  }

  Widget _actionCard(BuildContext context, String title, String sub, IconData icon, {Color? color, required VoidCallback onTap}) {
    final base = color ?? Colors.indigo;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(radius: 20, backgroundColor: base.withOpacity(0.12), child: Icon(icon, color: base)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(sub, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const Spacer(),
            Align(alignment: Alignment.bottomRight, child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26)),
          ]),
        ),
      ),
    );
  }
}
