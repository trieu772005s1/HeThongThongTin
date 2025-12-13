import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoanStep2_3 extends StatefulWidget {
  final int amount;
  final String purposeCode;
  final String receiveMethodCode;
  final String accountNumber;
  final int termMonths;

  const LoanStep2_3({
    super.key,
    required this.amount,
    required this.purposeCode,
    required this.receiveMethodCode,
    required this.accountNumber,
    required this.termMonths,
  });

  @override
  State<LoanStep2_3> createState() => _LoanStep2_3State();
}

class _LoanStep2_3State extends State<LoanStep2_3> {
  bool _addressExpanded = true;
  bool _jobExpanded = true;
  bool _emergencyExpanded = true;
  bool _incomeDocExpanded = true;

  String _formatAmount(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      buffer.write(str[i]);
      final posFromEnd = str.length - i - 1;
      if (posFromEnd % 3 == 0 && posFromEnd != 0) buffer.write('.');
    }
    return buffer.toString();
  }

  String _purposeText(String code) {
    switch (code) {
      case 'tieu_dung':
        return 'Tiêu dùng cá nhân';
      case 'kinh_doanh':
        return 'Kinh doanh';
      default:
        return 'Mục đích khác';
    }
  }

  String _receiveMethodText(String code) {
    switch (code) {
      case 'mb':
        return 'Qua tài khoản MB';
      case 'other':
        return 'Qua tài khoản ngân hàng khác';
      default:
        return 'Tại quầy';
    }
  }

  String _getField(Map<String, dynamic> data, String key) {
    return (data[key] ?? '').toString().trim();
  }

  bool _anyEmpty(Map<String, dynamic> data, List<String> keys) {
    for (final k in keys) {
      if (_getField(data, k).isEmpty) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bước 3/3', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Lưu và thoát',
              style: TextStyle(
                color: Color(0xFF1976D2),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: 1, // bước 3/3 nên full
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF1976D2),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: currentUser == null
                ? const Center(
                    child: Text(
                      'Bạn chưa đăng nhập, không thể hiển thị thông tin.',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data = snapshot.data?.data() ?? <String, dynamic>{};

                      final addressMissing = _anyEmpty(data, [
                        'permanentAddress',
                        'contactAddress',
                        'housingStatus',
                        'livingDuration',
                      ]);

                      final jobMissing = _anyEmpty(data, [
                        'jobTitle',
                        'companyName',
                        'position',
                        'workingDuration',
                        'monthlyIncome',
                        'incomeReceiveMethod',
                      ]);

                      final emergencyMissing = _anyEmpty(data, [
                        'emergency1Name',
                        'emergency1Relation',
                        'emergency1Phone',
                        'emergency2Name',
                        'emergency2Relation',
                        'emergency2Phone',
                      ]);

                      final incomeDocMissing = _getField(
                        data,
                        'incomeProofDescription',
                      ).isEmpty;

                      final hasMissing =
                          addressMissing ||
                          jobMissing ||
                          emergencyMissing ||
                          incomeDocMissing;

                      // tên + CMND/CCCD
                      String name =
                          currentUser.displayName ??
                          currentUser.email ??
                          'Khách hàng';
                      String idNumber = _getField(data, 'idNumber');

                      final amountText = '${_formatAmount(widget.amount)} VND';

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Xác nhận thông tin',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Vui lòng kiểm tra lại toàn bộ thông tin trước khi gửi hồ sơ.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 20),

                            /// Card khoản vay
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Khoản vay của bạn',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _kvRow('Số tiền vay', amountText),
                                    _kvRow(
                                      'Thời gian cấp hạn mức',
                                      '${widget.termMonths} tháng',
                                    ),
                                    _kvRow(
                                      'Mục đích vay',
                                      _purposeText(widget.purposeCode),
                                    ),
                                    _kvRow(
                                      'Hình thức nhận tiền',
                                      _receiveMethodText(
                                        widget.receiveMethodCode,
                                      ),
                                    ),
                                    _kvRow(
                                      'Số tài khoản nhận',
                                      widget.accountNumber,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            /// Họ tên + CCCD
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Thông tin khách hàng',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _kvRow('Họ và tên', name),
                                    _kvRow(
                                      'Số CMND/CCCD',
                                      idNumber.isEmpty
                                          ? '(Chưa có dữ liệu)'
                                          : idNumber,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            /// SECTION: Địa chỉ liên hệ
                            _sectionHeader(
                              icon: Icons.location_on_outlined,
                              title: 'Địa chỉ liên hệ',
                              expanded: _addressExpanded,
                              missing: addressMissing,
                              onTap: () {
                                setState(() {
                                  _addressExpanded = !_addressExpanded;
                                });
                              },
                            ),
                            if (_addressExpanded)
                              _sectionCard(
                                children: [
                                  _kvRow(
                                    'Địa chỉ thường trú',
                                    _getField(data, 'permanentAddress'),
                                  ),
                                  _kvRow(
                                    'Địa chỉ liên hệ',
                                    _getField(data, 'contactAddress'),
                                  ),
                                  _kvRow(
                                    'Tình trạng chỗ ở',
                                    _getField(data, 'housingStatus'),
                                  ),
                                  _kvRow(
                                    'Thời gian sinh sống\n'
                                    'tại địa chỉ liên hệ',
                                    _getField(data, 'livingDuration'),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 12),

                            /// SECTION: Nghề nghiệp và thu nhập
                            _sectionHeader(
                              icon: Icons.attach_money_outlined,
                              title: 'Nghề nghiệp và thu nhập',
                              expanded: _jobExpanded,
                              missing: jobMissing,
                              onTap: () {
                                setState(() {
                                  _jobExpanded = !_jobExpanded;
                                });
                              },
                            ),
                            if (_jobExpanded)
                              _sectionCard(
                                children: [
                                  _kvRow(
                                    'Nghề nghiệp',
                                    _getField(data, 'jobTitle'),
                                  ),
                                  _kvRow(
                                    'Tên đơn vị công\n'
                                    'tác/kinh doanh',
                                    _getField(data, 'companyName'),
                                  ),
                                  _kvRow(
                                    'Chức vụ',
                                    _getField(data, 'position'),
                                  ),
                                  _kvRow(
                                    'Thời gian làm việc',
                                    _getField(data, 'workingDuration'),
                                  ),
                                  _kvRow(
                                    'Thu nhập bình\nquân/tháng',
                                    _getField(data, 'monthlyIncome'),
                                  ),
                                  _kvRow(
                                    'Hình thức nhận\nthu nhập',
                                    _getField(data, 'incomeReceiveMethod'),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 12),

                            /// SECTION: Người liên hệ khẩn cấp
                            _sectionHeader(
                              icon: Icons.person_outline,
                              title: 'Người liên hệ khẩn cấp',
                              expanded: _emergencyExpanded,
                              missing: emergencyMissing,
                              onTap: () {
                                setState(() {
                                  _emergencyExpanded = !_emergencyExpanded;
                                });
                              },
                            ),
                            if (_emergencyExpanded)
                              _sectionCard(
                                children: [
                                  const Text(
                                    'Người liên hệ khẩn cấp 1',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _kvRow(
                                    'Họ và tên',
                                    _getField(data, 'emergency1Name'),
                                  ),
                                  _kvRow(
                                    'Mối quan hệ',
                                    _getField(data, 'emergency1Relation'),
                                  ),
                                  _kvRow(
                                    'Số điện thoại',
                                    _getField(data, 'emergency1Phone'),
                                    valueColor: Colors.red,
                                    // nếu trống sẽ tự ra trống
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Người liên hệ khẩn cấp 2',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _kvRow(
                                    'Họ và tên',
                                    _getField(data, 'emergency2Name'),
                                  ),
                                  _kvRow(
                                    'Mối quan hệ',
                                    _getField(data, 'emergency2Relation'),
                                  ),
                                  _kvRow(
                                    'Số điện thoại',
                                    _getField(data, 'emergency2Phone'),
                                    valueColor: Colors.red,
                                  ),
                                ],
                              ),
                            const SizedBox(height: 12),

                            /// SECTION: Giấy tờ chứng minh thu nhập
                            _sectionHeader(
                              icon: Icons.image_outlined,
                              title: 'Giấy tờ chứng minh thu nhập',
                              expanded: _incomeDocExpanded,
                              missing: incomeDocMissing,
                              onTap: () {
                                setState(() {
                                  _incomeDocExpanded = !_incomeDocExpanded;
                                });
                              },
                            ),
                            if (_incomeDocExpanded)
                              _sectionCard(
                                children: [
                                  _kvRow(
                                    'Thông tin giấy tờ',
                                    _getField(data, 'incomeProofDescription'),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Thanh bottom: Sửa thông tin + Gửi thông tin
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -1),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.05),
                ),
              ],
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => _showEditOptions(context),
                  child: const Text(
                    'Sửa thông tin',
                    style: TextStyle(
                      color: Color(0xFF1976D2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const Spacer(),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      // gửi hồ sơ – sau này bạn call API, giờ trả true về step trước
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      'Gửi thông tin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================== WIDGET PHỤ ==================

  Widget _kvRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 7,
            child: Text(
              value.isEmpty ? 'Chưa có thông tin' : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF002B5C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required bool expanded,
    required bool missing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF002B5C)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF002B5C),
              ),
            ),
          ),
          if (missing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEF0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Thiếu thông tin',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const Icon(Icons.check_circle, size: 18, color: Color(0xFF4CAF50)),
          const SizedBox(width: 8),
          Icon(
            expanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.grey.shade700,
          ),
        ],
      ),
    );
  }

  void _showEditOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Chọn mục cần sửa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              _editItem(
                context,
                icon: Icons.location_on_outlined,
                title: 'Địa chỉ liên hệ',
                route: '/loan_edit_address',
              ),
              _editItem(
                context,
                icon: Icons.attach_money_outlined,
                title: 'Nghề nghiệp & thu nhập',
                route: '/loan_edit_job',
              ),
              _editItem(
                context,
                icon: Icons.people_outline,
                title: 'Người liên hệ khẩn cấp',
                route: '/loan_edit_emergency',
              ),
              _editItem(
                context,
                icon: Icons.image_outlined,
                title: 'Giấy tờ chứng minh thu nhập',
                route: '/loan_edit_income_proof',
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _editItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1976D2)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
