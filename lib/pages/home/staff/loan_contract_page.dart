// lib/pages/home/staff/loan_contract_page.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoanContractPage extends StatefulWidget {
  const LoanContractPage({super.key});

  @override
  State<LoanContractPage> createState() => _LoanContractPageState();
}

class _LoanContractPageState extends State<LoanContractPage> {
  final _formKey = GlobalKey<FormState>();
  final _customerCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _interestCtrl = TextEditingController(text: '10'); // default 10%
  final _termCtrl = TextEditingController(text: '12'); // default 12 months
  DateTime _startDate = DateTime.now();
  bool _creating = false;
  bool _createSchedule = true;
  String _status = 'pending';

  final _currencyFormat = NumberFormat.decimalPattern();

  @override
  void dispose() {
    _customerCtrl.dispose();
    _amountCtrl.dispose();
    _interestCtrl.dispose();
    _termCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  double _parseDouble(String s) {
    return double.tryParse(s.replaceAll(',', '').trim()) ?? 0.0;
  }

  int _parseInt(String s) {
    return int.tryParse(s.trim()) ?? 0;
  }

  /// Annuity monthly payment formula
  /// A = P * r / (1 - (1 + r)^-n) where r is monthly rate (decimal), n months
  double _monthlyPayment(double principal, double annualRatePercent, int months) {
    if (months <= 0) return 0;
    final r = annualRatePercent / 100 / 12;
    if (r == 0) return principal / months;
    final denom = 1 - pow(1 + r, -months);
    if (denom == 0) return principal / months;
    return principal * r / denom;
  }

  /// Transaction-safe submit:
  /// - create loan doc with known id
  /// - use a transaction to flip scheduleCreated flag from false->true (only one writer succeeds)
  /// - if success, create repayments in a batch
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final customerId = _customerCtrl.text.trim();
    final amount = _parseDouble(_amountCtrl.text);
    final interest = _parseDouble(_interestCtrl.text);
    final termMonths = _parseInt(_termCtrl.text);

    if (amount <= 0 || termMonths <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số tiền và kỳ hạn phải lớn hơn 0')));
      return;
    }

    setState(() => _creating = true);

    try {
      final loansRef = FirebaseFirestore.instance.collection('loans');

      // create loan doc with known id
      final newLoanRef = loansRef.doc();
      await newLoanRef.set({
        'customerId': customerId,
        'amount': amount,
        'interestRate': interest,
        'termMonths': termMonths,
        'startDate': Timestamp.fromDate(_startDate),
        'status': _status,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'scheduleCreated': false,
      });

      debugPrint('Loan created (id): ${newLoanRef.id}');

      if (_createSchedule) {
        // transaction to ensure only one process creates schedule
        final bool iAmOwner = await FirebaseFirestore.instance.runTransaction<bool>((tx) async {
          final snap = await tx.get(newLoanRef);
          final data = snap.data();
          final bool already = (data != null && data['scheduleCreated'] == true);
          if (already) {
            return false;
          }
          tx.update(newLoanRef, {'scheduleCreated': true, 'updatedAt': FieldValue.serverTimestamp()});
          return true;
        });

        if (iAmOwner) {
          // we are responsible for creating schedule
          final col = newLoanRef.collection('repayments');
          final monthly = _monthlyPayment(amount, interest, termMonths);
          DateTime due = DateTime(_startDate.year, _startDate.month, _startDate.day);

          final WriteBatch batch = FirebaseFirestore.instance.batch();
          for (int i = 0; i < termMonths; i++) {
            final pay = monthly.floorToDouble();
            final repayDoc = col.doc();
            batch.set(repayDoc, {
              'amount': pay,
              'status': 'scheduled',
              'dueDate': Timestamp.fromDate(due),
              'createdAt': FieldValue.serverTimestamp(),
            });
            // increment month safely (DateTime will normalize month overflow)
            due = DateTime(due.year, due.month + 1, due.day);
          }
          await batch.commit();
          debugPrint('Repayment schedule created for ${newLoanRef.id}');
        } else {
          debugPrint('Schedule was already created by another process for ${newLoanRef.id}');
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo hợp đồng thành công')));
      Navigator.pushReplacementNamed(context, '/loanDetail', arguments: {'loanId': newLoanRef.id});
    } catch (e, st) {
      debugPrint('Create loan error: $e\n$st');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi tạo hợp đồng: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  // Utility: delete all repayments for a loan (admin/debug)
  Future<void> deleteAllRepaymentsForLoan(String loanId) async {
    final loanRef = FirebaseFirestore.instance.collection('loans').doc(loanId);
    final snaps = await loanRef.collection('repayments').get();
    if (snaps.docs.isEmpty) {
      debugPrint('No repayments to delete for $loanId');
      return;
    }
    final batch = FirebaseFirestore.instance.batch();
    for (final d in snaps.docs) batch.delete(d.reference);
    await batch.commit();
    debugPrint('Deleted ${snaps.docs.length} repayments for $loanId');
  }

  // Utility: dedupe repayments keeping earliest by dueDate (admin/debug)
  Future<void> dedupeRepaymentsKeepOnePerDueDate(String loanId) async {
    final col = FirebaseFirestore.instance.collection('loans').doc(loanId).collection('repayments');
    final snaps = await col.orderBy('dueDate').orderBy('createdAt').get();
    if (snaps.docs.isEmpty) {
      debugPrint('No repayments for $loanId');
      return;
    }

    final Map<String, List<QueryDocumentSnapshot>> byDue = {};
    for (final d in snaps.docs) {
      final m = d.data() as Map<String, dynamic>? ?? {};
      final dueT = m['dueDate'];
      final key = dueT is Timestamp ? dueT.toDate().toIso8601String().substring(0, 10) : (dueT?.toString() ?? 'null');
      byDue.putIfAbsent(key, () => []).add(d);
    }

    int deleted = 0;
    for (final entry in byDue.entries) {
      final list = entry.value;
      if (list.length <= 1) continue;
      // keep the first (earliest created), delete others
      for (int i = 1; i < list.length; i++) {
        await list[i].reference.delete();
        deleted++;
      }
    }
    debugPrint('Dedupe done for $loanId, deleted $deleted duplicates');
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom + 16;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo hợp đồng'),
        elevation: 1,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Khách hàng (customerId)', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _customerCtrl,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'VD: Mth4S8dZzifOxp...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập customerId' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Số tiền', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _amountCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Ví dụ: 250000',
                                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                suffixText: 'VND',
                              ),
                              validator: (v) {
                                final n = _parseDouble(v ?? '');
                                if (n <= 0) return 'Số tiền không hợp lệ';
                                return null;
                              },
                            ),
                          ]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Lãi suất (năm %)', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _interestCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Ví dụ: 10',
                                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                suffixText: '%',
                              ),
                              validator: (v) {
                                final n = _parseDouble(v ?? '');
                                if (n < 0) return 'Lãi suất không hợp lệ';
                                return null;
                              },
                            ),
                          ]),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Kỳ hạn (tháng)', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _termCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Số tháng (ví dụ: 12)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                              ),
                              validator: (v) {
                                final n = _parseInt(v ?? '');
                                if (n <= 0) return 'Kỳ hạn không hợp lệ';
                                return null;
                              },
                            ),
                          ]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Ngày bắt đầu', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _pickStartDate,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                                alignment: Alignment.centerLeft,
                                child: Text(DateFormat.yMMMd().format(_startDate)),
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Checkbox(value: _createSchedule, onChanged: (v) => setState(() => _createSchedule = v ?? true)),
                        const SizedBox(width: 6),
                        const Expanded(child: Text('Tạo lịch thanh toán tự động (hàng tháng)')),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _status,
                          items: const [
                            DropdownMenuItem(value: 'pending', child: Text('pending')),
                            DropdownMenuItem(value: 'approved', child: Text('approved')),
                            DropdownMenuItem(value: 'rejected', child: Text('rejected')),
                          ],
                          onChanged: (v) => setState(() => _status = v ?? 'pending'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    // submit
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _creating ? null : _submit,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: _creating
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Tạo hợp đồng'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                  ],
                ),
              ),
            ),

            // optional helper / debug UI can be added here if needed
          ],
        ),
      ),
    );
  }
}
