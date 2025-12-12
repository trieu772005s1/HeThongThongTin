// lib/pages/home/staff/loan_contract_page.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class LoanContractPage extends StatefulWidget {
  const LoanContractPage({super.key});

  @override
  State<LoanContractPage> createState() => _LoanContractPageState();
}

class _LoanContractPageState extends State<LoanContractPage> {
  final _formKey = GlobalKey<FormState>();
  final _customerCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _interestCtrl = TextEditingController(text: '10');
  final _termCtrl = TextEditingController(text: '12');
  DateTime _startDate = DateTime.now();
  bool _creating = false;
  bool _createSchedule = true;
  String _status = 'pending';

  final NumberFormat _currencyFormat = NumberFormat.decimalPattern();
  final NumberFormat _monthFormat = NumberFormat('#,##0');

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

  double _parseDouble(String s) => double.tryParse(s.replaceAll(',', '').trim()) ?? 0.0;
  int _parseInt(String s) => int.tryParse(s.trim()) ?? 0;

  double _monthlyPayment(double principal, double annualRatePercent, int months) {
    if (months <= 0) return 0;
    final r = annualRatePercent / 100 / 12;
    if (r == 0) return principal / months;
    final denom = 1 - pow(1 + r, -months);
    if (denom == 0) return principal / months;
    return principal * r / denom;
  }

  int _monthlyPaymentRounded(double principal, double annualRatePercent, int months) {
    final monthly = _monthlyPayment(principal, annualRatePercent, months);
    // round to nearest integer (no decimal places)
    return monthly.isFinite ? monthly.round() : 0;
  }

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

      if (_createSchedule) {
        final bool iAmOwner = await FirebaseFirestore.instance.runTransaction<bool>((tx) async {
          final snap = await tx.get(newLoanRef);
          final data = snap.data();
          final bool already = (data != null && data['scheduleCreated'] == true);
          if (already) return false;
          tx.update(newLoanRef, {'scheduleCreated': true, 'updatedAt': FieldValue.serverTimestamp()});
          return true;
        });

        if (iAmOwner) {
          final col = newLoanRef.collection('repayments');
          final monthlyRaw = _monthlyPayment(amount, interest, termMonths);
          final int monthly = monthlyRaw.isFinite ? monthlyRaw.round() : 0;
          DateTime due = DateTime(_startDate.year, _startDate.month, _startDate.day);

          final WriteBatch batch = FirebaseFirestore.instance.batch();
          for (int i = 0; i < termMonths; i++) {
            final repayDoc = col.doc();
            batch.set(repayDoc, {
              'amount': monthly,
              'status': 'scheduled',
              'dueDate': Timestamp.fromDate(due),
              'createdAt': FieldValue.serverTimestamp(),
            });
            due = DateTime(due.year, due.month + 1, due.day);
          }
          await batch.commit();
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

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildSummary(double amount, double interest, int term) {
    final monthly = _monthlyPayment(amount, interest, term);
    final monthlyRounded = monthly.isFinite ? monthly.round() : 0;
    final totalRepay = monthlyRounded * term;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.blue.shade50),
              child: const Icon(Icons.insights, size: 28, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Tóm tắt khoản vay', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: Text('Thanh toán hàng tháng', style: TextStyle(color: Colors.grey.shade700))),
                  Text('${_monthFormat.format(monthlyRounded)} VND', style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: Text('Tổng trả sau $term tháng', style: TextStyle(color: Colors.grey.shade700))),
                  Text('${_currencyFormat.format(totalRepay)} VND', style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffix, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffix: suffix,
      prefixIcon: icon != null ? Icon(icon) : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom + 16;
    final amountVal = _parseDouble(_amountCtrl.text);
    final interestVal = _parseDouble(_interestCtrl.text);
    final termVal = _parseInt(_termCtrl.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo hợp đồng'),
        elevation: 1,
      ),
      backgroundColor: Colors.grey.shade100,
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
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('Thông tin khách hàng'),
                            TextFormField(
                              controller: _customerCtrl,
                              decoration: _inputDecoration(hint: 'VD: Mth4S8dZzifOxp...', icon: Icons.person),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập customerId' : null,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('Chi tiết khoản vay'),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _amountCtrl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: _inputDecoration(
                                      hint: 'Số tiền (VND)',
                                      suffix: Text('VND', style: TextStyle(color: Colors.grey.shade700)),
                                      icon: Icons.currency_exchange,
                                    ),
                                    validator: (v) {
                                      final n = _parseDouble(v ?? '');
                                      if (n <= 0) return 'Số tiền không hợp lệ';
                                      return null;
                                    },
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _interestCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                    decoration: _inputDecoration(hint: 'Lãi suất (năm %)', suffix: const Text('%'), icon: Icons.percent),
                                    validator: (v) {
                                      final n = _parseDouble(v ?? '');
                                      if (n < 0) return 'Lãi suất không hợp lệ';
                                      return null;
                                    },
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _termCtrl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: _inputDecoration(hint: 'Số tháng', icon: Icons.schedule),
                                    validator: (v) {
                                      final n = _parseInt(v ?? '');
                                      if (n <= 0) return 'Kỳ hạn không hợp lệ';
                                      return null;
                                    },
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: _pickStartDate,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      height: 52,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                          const SizedBox(width: 10),
                                          Text(DateFormat.yMMMd().format(_startDate)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Checkbox(value: _createSchedule, onChanged: (v) => setState(() => _createSchedule = v ?? true)),
                                const SizedBox(width: 6),
                                Expanded(child: Text('Tạo lịch thanh toán tự động (hàng tháng)', style: TextStyle(color: Colors.grey.shade800))),
                                const SizedBox(width: 8),
                                Tooltip(
                                  message: 'Bỏ chọn nếu không muốn tạo schedule tự động.',
                                  child: Icon(Icons.info_outline, size: 18, color: Colors.grey.shade600),
                                )
                              ],
                            ),

                            const SizedBox(height: 12),

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
                                const Spacer(),
                                Text(
                                  'Số tiền: ${amountVal > 0 ? _currencyFormat.format(amountVal) : '-'}',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (amountVal > 0 && termVal > 0)
                      _buildSummary(amountVal, interestVal, termVal),

                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _creating ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _creating
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Tạo hợp đồng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
