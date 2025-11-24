import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AccountVerificationPage extends StatefulWidget {
  const AccountVerificationPage({super.key});

  @override
  State<AccountVerificationPage> createState() =>
      _AccountVerificationPageState();
}

class _AccountVerificationPageState extends State<AccountVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // Thông tin cơ bản
  final _fullNameController = TextEditingController();
  final _idNumberController = TextEditingController();

  // Địa chỉ
  final _permanentAddressController = TextEditingController();
  final _contactAddressController = TextEditingController();
  final _housingStatusController = TextEditingController();
  final _livingDurationController = TextEditingController();

  // Nghề nghiệp & thu nhập
  final _jobTitleController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _workingDurationController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _incomeReceiveMethodController = TextEditingController();

  // Liên hệ khẩn cấp
  final _emergency1NameController = TextEditingController();
  final _emergency1RelationController = TextEditingController();
  final _emergency1PhoneController = TextEditingController();
  final _emergency2NameController = TextEditingController();
  final _emergency2RelationController = TextEditingController();
  final _emergency2PhoneController = TextEditingController();

  // Giấy tờ chứng minh thu nhập (ảnh)
  File? _incomeProofImage;
  String? _incomeProofUrl;

  @override
  void dispose() {
    _fullNameController.dispose();
    _idNumberController.dispose();

    _permanentAddressController.dispose();
    _contactAddressController.dispose();
    _housingStatusController.dispose();
    _livingDurationController.dispose();

    _jobTitleController.dispose();
    _companyNameController.dispose();
    _positionController.dispose();
    _workingDurationController.dispose();
    _monthlyIncomeController.dispose();
    _incomeReceiveMethodController.dispose();

    _emergency1NameController.dispose();
    _emergency1RelationController.dispose();
    _emergency1PhoneController.dispose();
    _emergency2NameController.dispose();
    _emergency2RelationController.dispose();
    _emergency2PhoneController.dispose();

    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bạn chưa đăng nhập')));
        return;
      }

      final file = File(picked.path);

      final ref = firebase_storage.FirebaseStorage.instance.ref().child(
        'income_proofs/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      setState(() {
        _incomeProofImage = file;
        _incomeProofUrl = url;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tải ảnh thành công')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải ảnh: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bạn chưa đăng nhập')));
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        // Thông tin cơ bản
        'fullName': _fullNameController.text.trim(),
        'idNumber': _idNumberController.text.trim(),

        // Địa chỉ
        'permanentAddress': _permanentAddressController.text.trim(),
        'contactAddress': _contactAddressController.text.trim(),
        'housingStatus': _housingStatusController.text.trim(),
        'livingDuration': _livingDurationController.text.trim(),

        // Nghề nghiệp & thu nhập
        'jobTitle': _jobTitleController.text.trim(),
        'companyName': _companyNameController.text.trim(),
        'position': _positionController.text.trim(),
        'workingDuration': _workingDurationController.text.trim(),
        'monthlyIncome': _monthlyIncomeController.text.trim(),
        'incomeReceiveMethod': _incomeReceiveMethodController.text.trim(),

        // Liên hệ khẩn cấp
        'emergency1Name': _emergency1NameController.text.trim(),
        'emergency1Relation': _emergency1RelationController.text.trim(),
        'emergency1Phone': _emergency1PhoneController.text.trim(),
        'emergency2Name': _emergency2NameController.text.trim(),
        'emergency2Relation': _emergency2RelationController.text.trim(),
        'emergency2Phone': _emergency2PhoneController.text.trim(),

        // Link ảnh giấy tờ chứng minh thu nhập
        'incomeProofImageUrl': _incomeProofUrl ?? '',

        // QUAN TRỌNG: đánh dấu đã xác thực
        'isVerifiedAccount': true,
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu thông tin xác thực')),
      );

      // báo về màn trước là bước 1 đã xong
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lưu thất bại: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực tài khoản'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Thông tin cơ bản'),
                _field(
                  controller: _fullNameController,
                  label: 'Họ và tên',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                ),
                _field(
                  controller: _idNumberController,
                  label: 'Số CMND/CCCD',
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                ),

                _sectionTitle('Địa chỉ liên hệ'),
                _field(
                  controller: _permanentAddressController,
                  label: 'Địa chỉ thường trú',
                  maxLines: 2,
                ),
                _field(
                  controller: _contactAddressController,
                  label: 'Địa chỉ liên hệ',
                  maxLines: 2,
                ),
                _field(
                  controller: _housingStatusController,
                  label: 'Tình trạng chỗ ở (VD: Sở hữu, Thuê...)',
                ),
                _field(
                  controller: _livingDurationController,
                  label: 'Thời gian sinh sống tại địa chỉ liên hệ',
                ),

                _sectionTitle('Nghề nghiệp và thu nhập'),
                _field(controller: _jobTitleController, label: 'Nghề nghiệp'),
                _field(
                  controller: _companyNameController,
                  label: 'Tên đơn vị công tác/kinh doanh',
                ),
                _field(controller: _positionController, label: 'Chức vụ'),
                _field(
                  controller: _workingDurationController,
                  label: 'Thời gian làm việc',
                ),
                _field(
                  controller: _monthlyIncomeController,
                  label: 'Thu nhập bình quân/tháng',
                  keyboardType: TextInputType.number,
                ),
                _field(
                  controller: _incomeReceiveMethodController,
                  label: 'Hình thức nhận thu nhập',
                ),

                _sectionTitle('Người liên hệ khẩn cấp'),
                const Text(
                  'Người liên hệ khẩn cấp 1',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _field(
                  controller: _emergency1NameController,
                  label: 'Họ và tên',
                ),
                _field(
                  controller: _emergency1RelationController,
                  label: 'Mối quan hệ',
                ),
                _field(
                  controller: _emergency1PhoneController,
                  label: 'Số điện thoại',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Người liên hệ khẩn cấp 2',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _field(
                  controller: _emergency2NameController,
                  label: 'Họ và tên',
                ),
                _field(
                  controller: _emergency2RelationController,
                  label: 'Mối quan hệ',
                ),
                _field(
                  controller: _emergency2PhoneController,
                  label: 'Số điện thoại',
                  keyboardType: TextInputType.phone,
                ),

                _sectionTitle('Giấy tờ chứng minh thu nhập'),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tải lên ảnh giấy tờ (sao kê lương, HĐLĐ, bảng lương...)',
                      ),
                      const SizedBox(height: 12),
                      if (_incomeProofImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _incomeProofImage!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _saving ? null : _pickAndUploadImage,
                          icon: const Icon(Icons.upload),
                          label: const Text('Chọn ảnh từ thư viện'),
                        ),
                      ),
                      if (_incomeProofUrl != null &&
                          _incomeProofUrl!.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Đã tải ảnh lên máy chủ',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Lưu & hoàn tất bước 1',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
