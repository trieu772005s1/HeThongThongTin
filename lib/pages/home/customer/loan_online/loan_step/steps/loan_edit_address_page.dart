import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoanEditAddressPage extends StatefulWidget {
  const LoanEditAddressPage({super.key});

  @override
  State<LoanEditAddressPage> createState() => _LoanEditAddressPageState();
}

class _LoanEditAddressPageState extends State<LoanEditAddressPage> {
  final _formKey = GlobalKey<FormState>();

  final _permanentCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  String? _housingStatus; // ở cùng gia đình / thuê / sở hữu / khác
  String? _livingDuration; // <6 tháng, 6-12, 1-3 năm, >3 năm

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _permanentCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bạn chưa đăng nhập')));
        Navigator.pop(context, false);
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data() ?? {};
      _permanentCtrl.text = (data['permanentAddress'] ?? '').toString();
      _contactCtrl.text = (data['contactAddress'] ?? '').toString();
      _housingStatus = (data['housingStatus'] ?? '').toString().trim();
      _livingDuration = (data['livingDuration'] ?? '').toString().trim();

      // normalize empty -> null for dropdown
      if (_housingStatus != null && _housingStatus!.isEmpty)
        _housingStatus = null;
      if (_livingDuration != null && _livingDuration!.isEmpty)
        _livingDuration = null;
    } catch (_) {
      // ignore, keep empty
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    if (_housingStatus == null || _housingStatus!.isEmpty) {
      _toast('Vui lòng chọn tình trạng chỗ ở');
      return;
    }
    if (_livingDuration == null || _livingDuration!.isEmpty) {
      _toast('Vui lòng chọn thời gian sinh sống');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _toast('Bạn chưa đăng nhập');
      return;
    }

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'permanentAddress': _permanentCtrl.text.trim(),
        'contactAddress': _contactCtrl.text.trim(),
        'housingStatus': _housingStatus,
        'livingDuration': _livingDuration,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      _toast('Đã cập nhật địa chỉ');
      Navigator.pop(context, true);
    } catch (e) {
      _toast('Lỗi cập nhật: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Sửa địa chỉ liên hệ'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _card(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông tin địa chỉ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF002B5C),
                            ),
                          ),
                          const SizedBox(height: 12),

                          _label('Địa chỉ thường trú'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _permanentCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              'Nhập địa chỉ thường trú',
                            ),
                            validator: (v) {
                              final s = (v ?? '').trim();
                              if (s.isEmpty) return 'Không được để trống';
                              if (s.length < 8) return 'Nhập đầy đủ hơn';
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),
                          _label('Địa chỉ liên hệ hiện tại'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _contactCtrl,
                            textInputAction: TextInputAction.done,
                            decoration: _inputDecoration(
                              'Nhập địa chỉ liên hệ',
                            ),
                            validator: (v) {
                              final s = (v ?? '').trim();
                              if (s.isEmpty) return 'Không được để trống';
                              if (s.length < 8) return 'Nhập đầy đủ hơn';
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),
                          _label('Tình trạng chỗ ở'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _housingStatus,
                            items: const [
                              DropdownMenuItem(
                                value: 'Sở hữu',
                                child: Text('Sở hữu'),
                              ),
                              DropdownMenuItem(
                                value: 'Thuê nhà',
                                child: Text('Thuê nhà'),
                              ),
                              DropdownMenuItem(
                                value: 'Ở cùng gia đình',
                                child: Text('Ở cùng gia đình'),
                              ),
                              DropdownMenuItem(
                                value: 'Khác',
                                child: Text('Khác'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _housingStatus = v),
                            decoration: _inputDecoration('Chọn'),
                          ),

                          const SizedBox(height: 14),
                          _label('Thời gian sinh sống tại địa chỉ liên hệ'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _livingDuration,
                            items: const [
                              DropdownMenuItem(
                                value: '< 6 tháng',
                                child: Text('< 6 tháng'),
                              ),
                              DropdownMenuItem(
                                value: '6 - 12 tháng',
                                child: Text('6 - 12 tháng'),
                              ),
                              DropdownMenuItem(
                                value: '1 - 3 năm',
                                child: Text('1 - 3 năm'),
                              ),
                              DropdownMenuItem(
                                value: '> 3 năm',
                                child: Text('> 3 năm'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _livingDuration = v),
                            decoration: _inputDecoration('Chọn'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1976D2),
                            side: const BorderSide(color: Color(0xFF1976D2)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Lưu',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _card({required Widget child}) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.grey.shade300),
    ),
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF002B5C),
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF1976D2)),
    ),
  );
}
