import 'package:flutter/material.dart';

class LoanStep3Page extends StatelessWidget {
  const LoanStep3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text(
          'Bước 3/4',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),

      body: Column(
        children: [
          // ===== PROGRESS =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.75, // bước 3 / 4
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF1976D2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ===== CONTENT =====
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Xác nhận thông tin',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002B5C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vui lòng kiểm tra lại các thông tin đã cung cấp trước khi tiếp tục.',
                    style: TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 20),

                  _infoCard(
                    title: 'Thông tin cá nhân',
                    items: const {
                      'Họ và tên': 'Nguyễn Văn A',
                      'CMND/CCCD': '0123456789',
                      'Số điện thoại': '09xxxxxxxx',
                    },
                  ),

                  const SizedBox(height: 12),

                  _infoCard(
                    title: 'Khoản vay',
                    items: const {
                      'Số tiền vay': '20.000.000 VND',
                      'Thời hạn': '12 tháng',
                      'Mục đích vay': 'Tiêu dùng cá nhân',
                    },
                  ),

                  const SizedBox(height: 12),

                  _infoCard(
                    title: 'Hình thức nhận tiền',
                    items: const {
                      'Ngân hàng': 'MB Bank',
                      'Số tài khoản': '1234 **** **** 5678',
                    },
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // ===== BOTTOM BAR =====
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  offset: Offset(0, -2),
                  color: Color(0x14000000),
                ),
              ],
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Quay lại',
                    style: TextStyle(
                      color: Color(0xFF1976D2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigator.push sang Bước 4
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => LoanStep4Page()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Tiếp theo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== WIDGET PHỤ =====

  Widget _infoCard({
    required String title,
    required Map<String, String> items,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF002B5C),
              ),
            ),
            const SizedBox(height: 12),
            ...items.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        e.key,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Text(
                        e.value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF002B5C),
                        ),
                      ),
                    ),
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
