import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_credit/services/firestore_service.dart';

class LoanDetailPage extends StatefulWidget {
  final String loanId;

  const LoanDetailPage({super.key, required this.loanId});

  @override
  State<LoanDetailPage> createState() => _LoanDetailPageState();
}

class _LoanDetailPageState extends State<LoanDetailPage> {
  final _firestoreService = FirestoreService();
  bool _isUpdating = false;
  String? _currentStatus;

  final _statusOptions = ['pending', 'approved', 'rejected', 'closed'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết hợp đồng'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('loans')
            .doc(widget.loanId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Hợp đồng không tồn tại'));
          }

          final data = snapshot.data!.data()!;
          final amount = (data['amount'] ?? 0).toDouble();
          final interest = (data['interestRate'] ?? 0).toDouble();
          final term = (data['termMonths'] ?? 0).toInt();
          final customerId = (data['customerId'] ?? '---') as String;
          final status = (data['status'] ?? 'pending') as String;
          final createdAt = data['createdAt'] as Timestamp?;
          final startDate = data['startDate'] as Timestamp?;

          // KHỞI TẠO TRẠNG THÁI LẦN ĐẦU
          _currentStatus ??= status;

          final createdStr = createdAt != null
              ? '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}'
              : '---';

          final startStr = startDate != null
              ? '${startDate.toDate().day}/${startDate.toDate().month}/${startDate.toDate().year}'
              : '---';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Mã hợp đồng', widget.loanId),
                const SizedBox(height: 8),
                _infoRow('Khách hàng (uid)', customerId),
                const SizedBox(height: 8),
                _infoRow('Số tiền vay', '${amount.toStringAsFixed(0)} VND'),
                const SizedBox(height: 8),
                _infoRow('Lãi suất', '${interest.toStringAsFixed(1)}% / năm'),
                const SizedBox(height: 8),
                _infoRow('Thời hạn vay', '$term tháng'),
                const SizedBox(height: 8),
                _infoRow('Ngày bắt đầu', startStr),
                const SizedBox(height: 8),
                _infoRow('Ngày tạo', createdStr),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Trạng thái hợp đồng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // DROPDOWN CHỌN TRẠNG THÁI
                DropdownButtonFormField<String>(
                  value: _currentStatus,
                  items: _statusOptions.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _currentStatus = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // NÚT LƯU TRẠNG THÁI
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_currentStatus == null || _isUpdating)
                        ? null
                        : () async {
                            setState(() => _isUpdating = true);
                            try {
                              await _firestoreService.updateLoanStatus(
                                loanId: widget.loanId,
                                status: _currentStatus!,
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Cập nhật trạng thái thành công',
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi: $e')),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => _isUpdating = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Lưu trạng thái',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }
}
