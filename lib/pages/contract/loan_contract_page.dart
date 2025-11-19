import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_credit/services/firestore_service.dart';

class LoanContractPage extends StatefulWidget {
  const LoanContractPage({super.key});

  @override
  State<LoanContractPage> createState() => _LoanContractPageState();
}

class _LoanContractPageState extends State<LoanContractPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _interestController = TextEditingController();
  final _termController = TextEditingController();
  DateTime _startDate = DateTime.now();

  final _firestoreService = FirestoreService();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _interestController.dispose();
    _termController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _saveLoan() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chưa đăng nhập')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final amount = double.parse(_amountController.text.trim());
      final interest = double.parse(_interestController.text.trim());
      final term = int.parse(_termController.text.trim());

      final loanId = await _firestoreService.createLoan(
        customerId: user.uid,
        amount: amount,
        interestRate: interest,
        termMonths: term,
        startDate: _startDate,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo hợp đồng thành công (ID: $loanId)')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black26),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo hợp đồng vay'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số tiền vay (VND)',
                  border: inputBorder,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Nhập số tiền';
                  if (double.tryParse(v) == null) return 'Số tiền không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _interestController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Lãi suất (%/năm)',
                  border: inputBorder,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Nhập lãi suất';
                  if (double.tryParse(v) == null)
                    return 'Lãi suất không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _termController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Thời hạn vay (tháng)',
                  border: inputBorder,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Nhập thời hạn';
                  if (int.tryParse(v) == null) return 'Thời hạn không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ngày bắt đầu'),
                subtitle: Text(
                  '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickStartDate,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveLoan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Lưu hợp đồng',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
