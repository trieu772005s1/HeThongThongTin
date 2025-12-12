// lib/pages/home/staff/loan_list_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoanListPage extends StatefulWidget {
  const LoanListPage({super.key});

  @override
  State<LoanListPage> createState() => _LoanListPageState();
}

class _LoanListPageState extends State<LoanListPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  // toggle to force rebuild stream (pull-to-refresh)
  int _refreshKey = 0;

  Stream<QuerySnapshot> _loansStream() {
    // limit to 200 for performance on mobile; adjust as needed
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
    if (v == null) return '-';
    if (v is num) return v.toStringAsFixed(0);
    return v.toString();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
            // just toggle to rebuild; stream is realtime anyway
            setState(() => _refreshKey++);
            await Future.delayed(const Duration(milliseconds: 350));
          },
          child: Column(
            children: [
              // search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _query = v.trim()),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Tìm theo ID hoặc customerId...',
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() => _query = '');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // add quick filter button placeholder
                    IconButton(
                      tooltip: 'Bộ lọc',
                      onPressed: () {
                        // optional: show filter modal
                        showModalBottomSheet(
                            context: context,
                            builder: (_) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(mainAxisSize: MainAxisSize.min, children: [
                                  const Text('Bộ lọc (chưa triển khai)', style: TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 12),
                                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))
                                ]),
                              );
                            });
                      },
                      icon: const Icon(Icons.filter_list),
                    )
                  ],
                ),
              ),

              // list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  key: ValueKey(_refreshKey),
                  stream: _loansStream(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data?.docs ?? [];
                    // client-side filter: loanId contains or customerId contains (case-insensitive)
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
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search_off, size: 48, color: Colors.black26),
                              const SizedBox(height: 10),
                              const Text('Không tìm thấy khoản vay nào', style: TextStyle(color: Colors.black54)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _query = '');
                                  },
                                  child: const Text('Xóa tìm kiếm'))
                            ],
                          ),
                        ),
                      );
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
                        if (createdAt is Timestamp) {
                          final dt = createdAt.toDate();
                          createdLabel = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
                        }

                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.pushNamed(context, '/loanDetail', arguments: {'loanId': d.id});
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // left: avatar / icon
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(Icons.receipt_long, color: Colors.blue),
                                  ),
                                  const SizedBox(width: 12),
                                  // middle: info
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
                                        const SizedBox(width: 6),
                                        Text(createdLabel, style: const TextStyle(color: Colors.black45, fontSize: 12)),
                                      ]),
                                      const SizedBox(height: 6),
                                      Text('Khách: ${_short(customer)}', style: const TextStyle(color: Colors.black87)),
                                      const SizedBox(height: 6),
                                      Row(children: [
                                        Text('Số tiền: $amount', style: const TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 12),
                                        Chip(
                                          label: Text(status.isEmpty ? '-' : status),
                                          backgroundColor: _statusColor(status).withOpacity(0.12),
                                          labelStyle: TextStyle(color: _statusColor(status), fontWeight: FontWeight.w700, fontSize: 12),
                                        )
                                      ])
                                    ]),
                                  ),
                                  // menu
                                  PopupMenuButton<String>(
                                    onSelected: (v) async {
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
                                          // delete (also consider deleting repayments subcollection if needed)
                                          await FirebaseFirestore.instance.collection('loans').doc(d.id).delete();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa hợp đồng')));
                                          }
                                        }
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(value: 'detail', child: Text('Chi tiết')),
                                      const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                                    ],
                                  )
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
