// lib/pages/home/staff/repayment_list_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RepaymentListPage extends StatefulWidget {
  const RepaymentListPage({super.key});

  @override
  State<RepaymentListPage> createState() => _RepaymentListPageState();
}

class _RepaymentListPageState extends State<RepaymentListPage> {
  String? loanId;
  final TextEditingController _loanIdCtrl = TextEditingController();
  bool _loadingLoan = false;

  final NumberFormat _moneyFmt = NumberFormat.decimalPattern();
  final DateFormat _dateFmt = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void dispose() {
    _loanIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _touchLoan(String loanId) async {
    try {
      await FirebaseFirestore.instance.collection('loans').doc(loanId).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> _onAddPressed() async {
    if (loanId != null && loanId!.isNotEmpty) {
      await _showAddDialog(initialLoanId: loanId);
      return;
    }

    final id = await showDialog<String>(
      context: context,
      builder: (c) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Nhập Loan ID'),
          content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Loan ID')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Hủy')),
            ElevatedButton(onPressed: () => Navigator.pop(c, ctrl.text.trim()), child: const Text('OK')),
          ],
        );
      },
    );

    if (id != null && id.isNotEmpty) {
      setState(() {
        loanId = id;
        _loanIdCtrl.text = id;
      });
      await _showAddDialog(initialLoanId: id);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập Loan ID')));
    }
  }

  Future<void> _showAddDialog({String? initialLoanId}) async {
    final ctrlAmount = TextEditingController();
    final loanCtrl = TextEditingController(text: initialLoanId ?? _loanIdCtrl.text);
    String status = 'scheduled';
    DateTime? dueDate;

    await showDialog(
      context: context,
      builder: (c) {
        return StatefulBuilder(builder: (c2, setSt) {
          return AlertDialog(
            title: const Text('Thêm thanh toán'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (initialLoanId == null)
                  TextField(controller: loanCtrl, decoration: const InputDecoration(labelText: 'Loan ID (bắt buộc)')),
                TextField(
                  controller: ctrlAmount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số tiền'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: status,
                  items: const [
                    DropdownMenuItem(value: 'scheduled', child: Text('scheduled')),
                    DropdownMenuItem(value: 'paid', child: Text('paid')),
                    DropdownMenuItem(value: 'pending', child: Text('pending')),
                  ],
                  onChanged: (v) => setSt(() => status = v ?? 'scheduled'),
                  decoration: const InputDecoration(labelText: 'Trạng thái'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dueDate == null ? 'Không có ngày đến hạn' : 'Ngày đến hạn: ${_dateFmt.format(dueDate!)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Chọn ngày đến hạn',
                      icon: const Icon(Icons.calendar_today, size: 20),
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                            context: context, initialDate: now, firstDate: DateTime(now.year - 5), lastDate: DateTime(now.year + 10));
                        if (picked != null) {
                          final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          setSt(() {
                            if (t != null) dueDate = DateTime(picked.year, picked.month, picked.day, t.hour, t.minute);
                            else dueDate = DateTime(picked.year, picked.month, picked.day);
                          });
                        }
                      },
                    )
                  ],
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c2), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: () async {
                  final targetLoanId = (initialLoanId ?? loanCtrl.text).trim();
                  final amt = double.tryParse(ctrlAmount.text.trim().replaceAll(',', '')) ?? 0;
                  if (targetLoanId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loan ID bắt buộc')));
                    return;
                  }
                  if (amt <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số tiền không hợp lệ')));
                    return;
                  }
                  final loanRef = FirebaseFirestore.instance.collection('loans').doc(targetLoanId);
                  try {
                    final payload = {
                      'amount': amt,
                      'status': status,
                      'createdAt': FieldValue.serverTimestamp(),
                      if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!),
                      if (status == 'paid') 'paidAt': FieldValue.serverTimestamp(),
                    };
                    await loanRef.collection('repayments').add(payload);
                    await _touchLoan(targetLoanId);
                    if (!mounted) return;
                    Navigator.pop(c2);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm thanh toán')));
                    setState(() {
                      loanId = targetLoanId;
                      _loanIdCtrl.text = targetLoanId;
                    });
                  } catch (e) {
                    Navigator.pop(c2);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi thêm: $e')));
                  }
                },
                child: const Text('Thêm'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _showEditDialog(String loanId, QueryDocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ctrl = TextEditingController(text: (data['amount'] ?? '').toString());
    String status = (data['status'] ?? 'scheduled').toString();
    DateTime? dueDate;
    if (data['dueDate'] is Timestamp) dueDate = (data['dueDate'] as Timestamp).toDate();

    await showDialog(
      context: context,
      builder: (c) => StatefulBuilder(builder: (c2, setSt) {
        return AlertDialog(
          title: const Text('Chỉnh sửa thanh toán'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Loan ID: $loanId', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 8),
              TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số tiền')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'scheduled', child: Text('scheduled')),
                  DropdownMenuItem(value: 'paid', child: Text('paid')),
                  DropdownMenuItem(value: 'pending', child: Text('pending')),
                ],
                onChanged: (v) => setSt(() => status = v ?? status),
                decoration: const InputDecoration(labelText: 'Trạng thái'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text(dueDate == null ? 'Không có ngày đến hạn' : 'Ngày đến hạn: ${_dateFmt.format(dueDate!)}')),
                  IconButton(
                      icon: const Icon(Icons.calendar_today, size: 20),
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                            context: context, initialDate: dueDate ?? now, firstDate: DateTime(now.year - 5), lastDate: DateTime(now.year + 10));
                        if (picked != null) {
                          final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(dueDate ?? DateTime.now()));
                          setSt(() {
                            if (t != null) dueDate = DateTime(picked.year, picked.month, picked.day, t.hour, t.minute);
                            else dueDate = DateTime(picked.year, picked.month, picked.day);
                          });
                        }
                      })
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c2), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                final amt = double.tryParse(ctrl.text.trim().replaceAll(',', '')) ?? 0;
                if (amt <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số tiền không hợp lệ')));
                  return;
                }
                try {
                  final updatePayload = {
                    'amount': amt,
                    'status': status,
                    if (status == 'paid') 'paidAt': FieldValue.serverTimestamp(),
                    if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!),
                  };
                  await doc.reference.update(updatePayload);
                  await _touchLoan(loanId);
                  if (!mounted) return;
                  Navigator.pop(c2);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công')));
                } catch (e) {
                  Navigator.pop(c2);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _confirmDelete(String loanId, QueryDocumentSnapshot doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Xóa thanh toán'),
        content: const Text('Bạn có chắc muốn xóa thanh toán này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await doc.reference.delete();
        await _touchLoan(loanId);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  Future<void> _markPaid(String loanId, QueryDocumentSnapshot doc) async {
    try {
      await doc.reference.update({'status': 'paid', 'paidAt': FieldValue.serverTimestamp()});
      await _touchLoan(loanId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đánh dấu là paid')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Widget _buildLoanRepayments(String loanId) {
    final stream = FirebaseFirestore.instance
        .collection('loans')
        .doc(loanId)
        .collection('repayments')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('Stream error: ${snap.error}'));
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.payments_outlined, size: 56, color: Colors.black12),
              const SizedBox(height: 8),
              const Text('Chưa có thanh toán nào cho loan này.', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 10),
              ElevatedButton.icon(onPressed: () => _showAddDialog(initialLoanId: loanId), icon: const Icon(Icons.add), label: const Text('Thêm thanh toán')),
            ]),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final d = docs[index];
            final m = d.data() as Map<String, dynamic>? ?? {};
            final amtNum = (m['amount'] is num) ? m['amount'] as num : num.tryParse((m['amount'] ?? '').toString().replaceAll(',', '')) ?? 0;
            final amount = _moneyFmt.format(amtNum);
            final status = (m['status'] ?? '').toString();
            final createdAt = m['createdAt'] is Timestamp ? (m['createdAt'] as Timestamp).toDate() : null;
            final dueAt = m['dueDate'] is Timestamp ? (m['dueDate'] as Timestamp).toDate() : null;
            final paidAt = m['paidAt'] is Timestamp ? (m['paidAt'] as Timestamp).toDate() : null;

            final statusColor = _statusColor(status);

            return Material(
              color: Colors.white,
              elevation: 0,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showEditDialog(loanId, d),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // left: small status indicator (removed big avatar image per request)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 8, right: 12),
                        decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4)),
                      ),

                      // middle: main text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Số tiền: $amount VND', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 6),
                            if (dueAt != null)
                              Text('Hạn: ${_dateFmt.format(dueAt)}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            if (createdAt != null)
                              Text('Tạo: ${_dateFmt.format(createdAt)}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            if (paidAt != null)
                              Text('Thanh toán: ${_dateFmt.format(paidAt)}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                          ],
                        ),
                      ),

                      // right: status chip + menu
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status.isEmpty ? '-' : status,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // three dots menu
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
                                    const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                                    const PopupMenuItem(value: 'mark_paid', child: Text('Đánh dấu Paid')),
                                    const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                                  ],
                                );
                                if (v == null) return;
                                if (v == 'edit') await _showEditDialog(loanId, d);
                                if (v == 'mark_paid') await _markPaid(loanId, d);
                                if (v == 'delete') await _confirmDelete(loanId, d);
                              },
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.payments_outlined, size: 64, color: Colors.black12),
          const SizedBox(height: 12),
          const Text('Nhập Loan ID ở phía trên\nsau đó bấm Load để xem danh sách thanh toán.', textAlign: TextAlign.center),
          
        ]),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['loanId'] != null && loanId == null) {
      loanId = args['loanId'] as String;
      _loanIdCtrl.text = loanId!;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật thanh toán'),
        elevation: 1,
        actions: [
          IconButton(tooltip: 'Thêm thanh toán nhanh', icon: const Icon(Icons.add), onPressed: _onAddPressed),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _loanIdCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Nhập Loan ID để xem',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.credit_card_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final v = _loanIdCtrl.text.trim();
                      if (v.isEmpty) {
                        setState(() => loanId = null);
                        return;
                      }
                      setState(() {
                        _loadingLoan = true;
                        loanId = v;
                      });
                      // small UX delay so spinner shows
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (mounted) setState(() => _loadingLoan = false);
                    },
                    child: _loadingLoan ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Load'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      _loanIdCtrl.clear();
                      setState(() => loanId = null);
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: loanId != null ? _buildLoanRepayments(loanId!) : _buildEmptyState()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddPressed,
        child: const Icon(Icons.add),
      ),
    );
  }
}
