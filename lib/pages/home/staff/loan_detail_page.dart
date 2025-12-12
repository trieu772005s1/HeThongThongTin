// lib/pages/home/staff/loan_detail_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoanDetailPage extends StatelessWidget {
  const LoanDetailPage({super.key});

  String _shorten(String s, {int keep = 18}) {
    if (s.isEmpty) return s;
    if (s.length <= keep) return s;
    return '${s.substring(0, keep)}...';
  }

  String _formatTimestamp(dynamic t) {
    if (t == null) return '';
    if (t is Timestamp) {
      final d = t.toDate();
      return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}';
    }
    return t.toString();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final loanId = args?['loanId'] as String?;
    if (loanId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết')),
        body: const Center(child: Text('Không tìm thấy loanId')),
      );
    }

    final loanRef = FirebaseFirestore.instance.collection('loans').doc(loanId);
    final repaymentsRef = loanRef.collection('repayments').orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết: $loanId', overflow: TextOverflow.ellipsis),
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Loan info (streamed)
            StreamBuilder<DocumentSnapshot>(
              stream: loanRef.snapshots(),
              builder: (context, loanSnap) {
                if (loanSnap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: LinearProgressIndicator(),
                  );
                }
                if (!loanSnap.hasData || !loanSnap.data!.exists) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Hợp đồng không tồn tại', style: Theme.of(context).textTheme.bodyLarge),
                      ),
                    ),
                  );
                }

                final data = loanSnap.data!.data() as Map<String, dynamic>;
                final customerId = (data['customerId'] ?? '').toString();
                final amount = data['amount']?.toString() ?? '-';
                final interest = data['interestRate']?.toString() ?? '-';
                final term = data['termMonths']?.toString() ?? '-';
                final status = data['status']?.toString() ?? '-';
                final createdAt = _formatTimestamp(data['createdAt']);
                final updatedAt = _formatTimestamp(data['updatedAt']);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // customer id in a small rounded box to avoid long single-line overflow
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Khách hàng: ${_shorten(customerId, keep: 40)}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            runSpacing: 6,
                            spacing: 16,
                            children: [
                              _smallInfo('Số tiền', amount),
                              _smallInfo('Lãi suất', '$interest%'),
                              _smallInfo('Kỳ hạn', '$term tháng'),
                              _smallInfo('Trạng thái', status),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('Tạo: $createdAt', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          if (updatedAt.isNotEmpty)
                            Text('Cập nhật: $updatedAt', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Buttons row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // mở trang cập nhật thanh toán (nếu bạn có route)
                        Navigator.pushNamed(context, '/repaymentList', arguments: {'loanId': loanId});
                      },
                      icon: const Icon(Icons.payment_outlined),
                      label: const Text('Thanh toán / Quản lý'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      // quick add dialog
                      final ctrl = TextEditingController();
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Thêm thanh toán nhanh'),
                          content: TextField(
                            controller: ctrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Số tiền'),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')),
                            ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Thêm')),
                          ],
                        ),
                      );
                      if (ok == true && ctrl.text.trim().isNotEmpty) {
                        final v = double.tryParse(ctrl.text.trim()) ?? 0;
                        await loanRef.collection('repayments').add({
                          'amount': v,
                          'status': 'paid',
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm thanh toán')));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                    ),
                    child: const Icon(Icons.add),
                  )
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Title for repayments
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Thanh toán (repayments)', style: Theme.of(context).textTheme.titleMedium)),
            ),
            const SizedBox(height: 8),

            // Repayments list — use Expanded so list scrolls without overflow
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: StreamBuilder<QuerySnapshot>(
                  stream: repaymentsRef.snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('Chưa có thanh toán nào.'));
                    }

                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 8),
                      itemBuilder: (c, i) {
                        final d = docs[i];
                        final m = d.data() as Map<String, dynamic>;
                        final amount = (m['amount'] ?? '').toString();
                        final status = (m['status'] ?? '').toString();
                        final created = _formatTimestamp(m['createdAt']);

                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            title: Text('Số tiền: $amount', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('Trạng thái: $status${created.isNotEmpty ? ' · $created' : ''}'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (v) async {
                                if (v == 'delete') {
                                  await d.reference.delete();
                                } else if (v == 'mark_paid') {
                                  await d.reference.update({'status': 'paid'});
                                } else if (v == 'mark_scheduled') {
                                  await d.reference.update({'status': 'scheduled'});
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'mark_paid', child: Text('Đánh dấu đã trả')),
                                const PopupMenuItem(value: 'mark_scheduled', child: Text('Đặt lịch')),
                                const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallInfo(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
