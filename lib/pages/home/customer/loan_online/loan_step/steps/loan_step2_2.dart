import 'package:flutter/material.dart';
import 'loan_step2_3.dart';

class LoanStep2_2 extends StatefulWidget {
  const LoanStep2_2({super.key});

  @override
  State<LoanStep2_2> createState() => _LoanStep2_2State();
}

class _LoanStep2_2State extends State<LoanStep2_2> {
  final double _minAmount = 3000000;
  final double _maxAmount = 20000000;
  double _amount = 10000000;

  String? _purpose;
  String? _receiveMethod = 'mb';
  final TextEditingController _accountController = TextEditingController(
    text: '0833680439',
  );
  bool _agreeInsurance = true;

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _agreeInsurance &&
      _purpose != null &&
      _receiveMethod != null &&
      _accountController.text.trim().isNotEmpty;

  String _formatAmount(double value) {
    final str = value.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      buffer.write(str[i]);
      final posFromEnd = str.length - i - 1;
      if (posFromEnd % 3 == 0 && posFromEnd != 0) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  Future<void> _onContinue() async {
    if (!_canContinue) return;

    final confirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LoanStep2_3(
          amount: _amount.round(),
          purposeCode: _purpose!, // truyền code, hiển thị text ở step 3
          receiveMethodCode: _receiveMethod!,
          accountNumber: _accountController.text.trim(),
          termMonths: 36,
        ),
      ),
    );

    // báo hoàn tất bước 2.x về LoanStep2_1 / LoanStepPage
    if (!mounted) return;
    Navigator.pop(context, confirmed == true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text('Bước 2/3', style: TextStyle(color: Colors.black)),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: 2 / 3,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF1976D2),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bạn cần vay bao nhiêu?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Text('Tôi mong muốn vay'),
                      SizedBox(width: 4),
                      Icon(Icons.help_outline, size: 18, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatAmount(_amount)} VND',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: _amount,
                    min: _minAmount,
                    max: _maxAmount,
                    divisions: 17,
                    activeColor: const Color(0xFF1976D2),
                    onChanged: (v) => setState(() => _amount = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('3 triệu VND', style: TextStyle(color: Colors.grey)),
                      Text(
                        '20 triệu VND',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F3FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              Icons.info,
                              size: 18,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                          WidgetSpan(child: SizedBox(width: 8)),
                          TextSpan(
                            text:
                                'Bạn cần cung cấp ít nhất 1 trong 2 loại giấy tờ: ',
                          ),
                          TextSpan(
                            text: 'chứng minh nơi ở',
                            style: TextStyle(color: Color(0xFF1976D2)),
                          ),
                          TextSpan(text: ' hoặc '),
                          TextSpan(
                            text: 'chứng minh tài chính',
                            style: TextStyle(color: Color(0xFF1976D2)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: const [
                      Text('Thời gian cấp hạn mức'),
                      SizedBox(width: 4),
                      Icon(Icons.help_outline, size: 18, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '36 tháng',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  const Text('Mục đích vay'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _purpose,
                    items: const [
                      DropdownMenuItem(
                        value: 'tieu_dung',
                        child: Text('Tiêu dùng cá nhân'),
                      ),
                      DropdownMenuItem(
                        value: 'kinh_doanh',
                        child: Text('Kinh doanh'),
                      ),
                      DropdownMenuItem(
                        value: 'khac',
                        child: Text('Mục đích khác'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _purpose = value),
                    decoration: const InputDecoration(
                      hintText: 'Chọn một lựa chọn',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Hình thức nhận tiền vay'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _receiveMethod,
                    items: const [
                      DropdownMenuItem(
                        value: 'mb',
                        child: Text('Chuyển khoản vào ngân hàng '),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Text('Nhận tiền mặt tại điểm giao dịch'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _receiveMethod = value),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Số tài khoản'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _accountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF1F5FB),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeInsurance,
                        activeColor: const Color(0xFF1976D2),
                        onChanged: (v) =>
                            setState(() => _agreeInsurance = v ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          'Tôi đồng ý tham gia bảo hiểm sau khi đã đọc và hiểu rõ Phạm vi bảo hiểm',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canContinue ? _onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
