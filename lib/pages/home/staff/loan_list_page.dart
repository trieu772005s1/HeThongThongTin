// lib/pages/home/staff/loan_list_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoanListPage extends StatefulWidget {
  const LoanListPage({super.key});

  @override
  State<LoanListPage> createState() => _LoanListPageState();
}

class _LoanListPageState extends State<LoanListPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  int _refreshKey = 0;
  final NumberFormat _moneyFmt = NumberFormat.decimalPattern();

  Stream<QuerySnapshot> _loansStream() {
    return FirebaseFirestore.instance
        .collection('loans')
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red.shade400;
      case 'paid':
        return Colors.green;
      case 'approved':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _fmtMoney(dynamic v) {
    try {
      if (v == null) return '-';
      if (v is num) return _moneyFmt.format(v);
      final n = num.tryParse(v.toString().replaceAll(',', ''));
      if (n == null) return v.toString();
      return _moneyFmt.format(n);
    } catch (_) {
      // defensive fallback
      return v?.toString() ?? '-';
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _buildEmpty(String title, String subtitle, {VoidCallback? onAction, String? actionLabel}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.black12),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.black45), textAlign: TextAlign.center),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách khoản vay'),
        elevation: 1,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() => _refreshKey++);
            await Future.delayed(const Duration(milliseconds: 350));
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            const Icon(Icons.search, color: Colors.black45),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: (v) => setState(() => _query = v.trim()),
                                textInputAction: TextInputAction.search,
                                decoration: const InputDecoration(
                                  hintText: 'Tìm theo ID hoặc customerId...',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (_query.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _query = '');
                                },
                              ),
                            const SizedBox(width: 6),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'Bộ lọc',
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                          builder: (_) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                const Text('Bộ lọc', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 12),
                                ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))
                              ]),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.filter_list),
                    )
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  key: ValueKey(_refreshKey),
                  stream: _loansStream(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data?.docs ?? [];
                    final q = _query.toLowerCase();
                    final filtered = q.isEmpty
                        ? docs
                        : docs.where((d) {
                            final data = d.data() as Map<String, dynamic>? ?? {};
                            final cid = (data['customerId'] ?? '').toString().toLowerCase();
                            final id = d.id.toLowerCase();
                            return id.contains(q) || cid.contains(q);
                          }).toList();

                    if (filtered.isEmpty) {
                      if (q.isEmpty) {
                        return _buildEmpty('Chưa có khoản vay', 'Chưa có dữ liệu khoản vay để hiển thị.', onAction: () {
                          setState(() => _refreshKey++);
                        }, actionLabel: 'Làm mới');
                      } else {
                        return _buildEmpty('Không tìm thấy khoản vay', 'Thử xóa từ khóa tìm kiếm hoặc kiểm tra lại ID.', onAction: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        }, actionLabel: 'Xóa tìm kiếm');
                      }
                    }

                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, mq.viewPadding.bottom + 16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final d = filtered[index];
                        final data = d.data() as Map<String, dynamic>? ?? {};
                        final amount = _fmtMoney(data['amount']);
                        final status = (data['status'] ?? '').toString();
                        final customer = (data['customerId'] ?? '').toString();
                        final createdAt = data['createdAt'];

                        String createdLabel = '';
                        try {
                          if (createdAt is Timestamp) {
                            final dt = createdAt.toDate();
                            createdLabel = DateFormat('yyyy-MM-dd').format(dt);
                          } else if (createdAt is String) {
                            // if DB stored as ISO string
                            createdLabel = createdAt.split('T').first;
                          } else {
                            createdLabel = '';
                          }
                        } catch (_) {
                          // defensive fallback
                          try {
                            if (createdAt is Timestamp) createdLabel = createdAt.toDate().toIso8601String().split('T').first;
                          } catch (_) {
                            createdLabel = '';
                          }
                        }

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.pushNamed(context, '/loanDetail', arguments: {'loanId': d.id});
                            },
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))
                              ]),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(Icons.receipt_long, color: Colors.blue),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Row(children: [
                                        Expanded(
                                          child: Text(
                                            'ID: ${d.id}',
                                            style: const TextStyle(fontWeight: FontWeight.w700),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(createdLabel, style: const TextStyle(color: Colors.black45, fontSize: 12)),
                                      ]),
                                      const SizedBox(height: 8),
                                      Text('Khách: ${_short(customer)}', style: const TextStyle(color: Colors.black87)),
                                      const SizedBox(height: 8),
                                      Row(children: [
                                        Expanded(child: Text('Số tiền: $amount', style: const TextStyle(fontWeight: FontWeight.w600))),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _statusColor(status).withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            status.isEmpty ? '-' : status,
                                            style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.w700, fontSize: 12),
                                          ),
                                        ),
                                      ])
                                    ]),
                                  ),
                                  const SizedBox(width: 8),
                                  Builder(builder: (ctx) {
                                    return IconButton(
                                      icon: const Icon(Icons.more_vert),
                                      onPressed: () async {
                                        final RenderBox button = ctx.findRenderObject() as RenderBox;
                                        final RenderBox overlay = Overlay.of(ctx).context.findRenderObject() as RenderBox;
                                        final RelativeRect position = RelativeRect.fromRect(
                                          Rect.fromPoints(
                                            button.localToGlobal(Offset.zero, ancestor: overlay),
                                            button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                                          ),
                                          Offset.zero & overlay.size,
                                        );

                                        final v = await showMenu<String>(
                                          context: ctx,
                                          position: position,
                                          items: [
                                            const PopupMenuItem(value: 'detail', child: Text('Chi tiết')),
                                            const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                                          ],
                                        );

                                        if (v == null) return;
                                        if (v == 'detail') {
                                          Navigator.pushNamed(context, '/loanDetail', arguments: {'loanId': d.id});
                                        } else if (v == 'delete') {
                                          final ok = await showDialog<bool>(
                                            context: context,
                                            builder: (c) => AlertDialog(
                                              title: const Text('Xác nhận'),
                                              content: const Text('Xóa hợp đồng này?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')),
                                                ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Xóa')),
                                              ],
                                            ),
                                          );
                                          if (ok == true) {
                                            await FirebaseFirestore.instance.collection('loans').doc(d.id).delete();
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa hợp đồng')));
                                            }
                                          }
                                        }
                                      },
                                    );
                                  })
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _short(String s, {int keep = 18}) {
    if (s.isEmpty) return '-';
    if (s.length <= keep) return s;
    return '${s.substring(0, keep)}...';
  }
}
