// lib/pages/home/staff/repayment_list_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RepaymentListPage extends StatefulWidget {
  const RepaymentListPage({super.key});

  @override
  State<RepaymentListPage> createState() => _RepaymentListPageState();
}

class _RepaymentListPageState extends State<RepaymentListPage> {
  String? loanId;
  final TextEditingController _loanIdCtrl = TextEditingController();
  bool _loadingLoan = false;

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

  // Bấm nút + ở AppBar
  Future<void> _onAddPressed() async {
    if (loanId != null && loanId!.isNotEmpty) {
      await _showAddDialog(initialLoanId: loanId);
      return;
    }

    // Chưa có Loan ID -> hỏi trước
    final id = await showDialog<String>(
      context: context,
      builder: (c) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Nhập Loan ID'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: 'Loan ID'),
          ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Loan ID')),
      );
    }
  }

  // Dialog thêm repayment
  Future<void> _showAddDialog({String? initialLoanId}) async {
    final ctrlAmount = TextEditingController();
    final loanCtrl = TextEditingController(text: initialLoanId ?? _loanIdCtrl.text);
    String status = 'scheduled';
    final lidProvided = initialLoanId != null;

    await showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: const Text('Thêm thanh toán'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!lidProvided)
                TextField(
                  controller: loanCtrl,
                  decoration: const InputDecoration(labelText: 'Loan ID (bắt buộc)'),
                ),
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
                onChanged: (v) => status = v ?? 'scheduled',
                decoration: const InputDecoration(labelText: 'Trạng thái'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                final targetLoanId = (initialLoanId ?? loanCtrl.text).trim();
                final amt = double.tryParse(
                      ctrlAmount.text.trim().replaceAll(',', ''),
                    ) ??
                    0;
                if (targetLoanId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Loan ID bắt buộc')),
                  );
                  return;
                }
                if (amt <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Số tiền không hợp lệ')),
                  );
                  return;
                }

                final loanRef = FirebaseFirestore.instance.collection('loans').doc(targetLoanId);
                try {
                  await loanRef.collection('repayments').add({
                    'amount': amt,
                    'status': status,
                    'createdAt': FieldValue.serverTimestamp(),
                    if (status == 'paid') 'paidAt': FieldValue.serverTimestamp(),
                  });
                  await _touchLoan(targetLoanId);
                  if (!mounted) return;
                  Navigator.pop(c);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã thêm thanh toán')),
                  );
                  setState(() {
                    loanId = targetLoanId;
                    _loanIdCtrl.text = targetLoanId;
                  });
                } catch (e) {
                  Navigator.pop(c);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi thêm: $e')),
                  );
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  // Dialog sửa repayment
  Future<void> _showEditDialog(String loanId, QueryDocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ctrl = TextEditingController(text: (data['amount'] ?? '').toString());
    String status = (data['status'] ?? 'scheduled').toString();

    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Chỉnh sửa thanh toán'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Loan ID: $loanId', style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
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
              onChanged: (v) => status = v ?? status,
              decoration: const InputDecoration(labelText: 'Trạng thái'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final amt = double.tryParse(
                    ctrl.text.trim().replaceAll(',', ''),
                  ) ??
                  0;
              if (amt <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Số tiền không hợp lệ')),
                );
                return;
              }
              try {
                await doc.reference.update({
                  'amount': amt,
                  'status': status,
                  if (status == 'paid') 'paidAt': FieldValue.serverTimestamp(),
                });
                await _touchLoan(loanId);
                if (!mounted) return;
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cập nhật thành công')),
                );
              } catch (e) {
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e')),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _markPaid(String loanId, QueryDocumentSnapshot doc) async {
    try {
      await doc.reference.update({
        'status': 'paid',
        'paidAt': FieldValue.serverTimestamp(),
      });
      await _touchLoan(loanId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đánh dấu là paid')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  // List repayments cho 1 loan
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
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Chưa có thanh toán nào cho loan này.', style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _showAddDialog(initialLoanId: loanId),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm thanh toán'),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final d = docs[index];
            final m = d.data() as Map<String, dynamic>? ?? {};
            final amount = (m['amount'] ?? '').toString();
            final status = (m['status'] ?? '').toString();
            final createdAt = (m['createdAt'] is Timestamp)
                ? (m['createdAt'] as Timestamp).toDate().toString()
                : '';
            final paidAt = (m['paidAt'] is Timestamp)
                ? (m['paidAt'] as Timestamp).toDate().toString()
                : '';

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text('Số tiền: $amount', style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trạng thái: $status'),
                    if (createdAt.isNotEmpty)
                      Text('Tạo: $createdAt', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    if (paidAt.isNotEmpty)
                      Text('Thanh toán: $paidAt', style: const TextStyle(fontSize: 12, color: Colors.green)),
                  ],
                ),
                // FIX: use showMenu positioned at the button so popup won't jump to top
                trailing: Builder(builder: (ctx) {
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
                        items: const [
                          PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                          PopupMenuItem(value: 'mark_paid', child: Text('Đánh dấu Paid')),
                          PopupMenuItem(value: 'delete', child: Text('Xóa')),
                        ],
                      );

                      if (v == null) return;
                      if (v == 'edit') await _showEditDialog(loanId, d);
                      if (v == 'mark_paid') await _markPaid(loanId, d);
                      if (v == 'delete') await _confirmDelete(loanId, d);
                    },
                  );
                }),
              ),
            );
          },
        );
      },
    );
  }

  // Khi chưa nhập Loan ID
  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Nhập Loan ID ở phía trên\nsau đó bấm Load để xem danh sách thanh toán.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // nhận loanId từ route arguments (nếu có)
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
          IconButton(
            tooltip: 'Thêm thanh toán nhanh',
            icon: const Icon(Icons.add),
            onPressed: _onAddPressed,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Ô nhập Loan ID + nút Load / Clear
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
                      // chỉ để hiện loading chút xíu
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (mounted) setState(() => _loadingLoan = false);
                    },
                    child: _loadingLoan
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Load'),
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
            Expanded(
              child: loanId != null ? _buildLoanRepayments(loanId!) : _buildEmptyState(),
            ),
          ],
        ),
      ),
    );
  }
}
