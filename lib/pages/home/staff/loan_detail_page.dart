import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LoanDetailPage extends StatelessWidget {
  const LoanDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String loanId = args['loanId'];
    final bool isAdmin = args['isAdmin'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FF),
      appBar: AppBar(title: const Text('Chi tiết hợp đồng'), centerTitle: true),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('loans')
            .doc(loanId)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'pending';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _summaryCard(data),
              const SizedBox(height: 16),

              _section('Thông tin khách hàng'),
              _infoCard([
                _row('Họ tên', data['customerName']),
                _row('SĐT', data['phone']),
                _row('CCCD', data['customerId']),
              ]),

              const SizedBox(height: 12),
              _section('Thông tin khoản vay'),
              _infoCard([
                _row('Số tiền vay', _money(data['amount'])),
                _row('Kỳ hạn', '${data['tenure']} tháng'),
                _row('Lãi suất', '${data['interest']} %'),
                _row('Ngày tạo', _date(data['createdAt'])),
              ]),

              const SizedBox(height: 16),
              _section('Trạng thái xử lý'),
              _statusTimeline(status),

              const SizedBox(height: 24),

              // ===== ACTIONS =====
              if (status == 'pending') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Duyệt'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () =>
                            _updateStatus(context, loanId, 'approved'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text('Từ chối'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () =>
                            _updateStatus(context, loanId, 'rejected'),
                      ),
                    ),
                  ],
                ),
              ],

              if (isAdmin) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Xóa hợp đồng (Admin)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _deleteLoan(context, loanId),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // ================= UI =================

  Widget _summaryCard(Map data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giá trị hợp đồng',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            _money(data['amount']),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    ),
  );

  Widget _infoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  Widget _row(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Text(
            value?.toString() ?? '-',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _statusTimeline(String status) {
    final steps = ['pending', 'approved', 'rejected'];

    return Column(
      children: steps.map((s) {
        final active = status == s;
        return ListTile(
          leading: Icon(
            active ? Icons.check_circle : Icons.radio_button_unchecked,
            color: active ? Colors.green : Colors.grey,
          ),
          title: Text(
            _statusText(s),
            style: TextStyle(
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ================= LOGIC =================

  static Future<void> _updateStatus(
    BuildContext context,
    String id,
    String status,
  ) async {
    await FirebaseFirestore.instance.collection('loans').doc(id).update({
      'status': status,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đã cập nhật trạng thái')));
  }

  static Future<void> _deleteLoan(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('loans').doc(id).delete();
      Navigator.pop(context);
    }
  }

  // ================= UTILS =================

  static String _money(num? v) =>
      NumberFormat.currency(locale: 'vi', symbol: '₫').format(v ?? 0);

  static String _date(Timestamp? t) =>
      t == null ? '-' : DateFormat('dd/MM/yyyy').format(t.toDate());

  static String _statusText(String s) {
    switch (s) {
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      default:
        return 'Chờ duyệt';
    }
  }
}
