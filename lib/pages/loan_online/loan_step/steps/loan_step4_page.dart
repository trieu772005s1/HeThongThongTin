import 'package:flutter/material.dart';

class LoanStep4Page extends StatelessWidget {
  const LoanStep4Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text(
          'Bước 4/4',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // PROGRESS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 1,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF1976D2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),

                  // Success icon
                  Container(
                    height: 88,
                    width: 88,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 54,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Gửi hồ sơ thành công',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002B5C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hồ sơ của bạn đã được tiếp nhận. Chúng tôi sẽ xét duyệt và phản hồi trong thời gian sớm nhất.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, height: 1.4),
                  ),

                  const SizedBox(height: 18),

                  // Summary card
                  Card(
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
                          const Text(
                            'Trạng thái hồ sơ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF002B5C),
                            ),
                          ),
                          const SizedBox(height: 12),

                          _kvRow('Trạng thái', 'Đang xét duyệt', chip: true),
                          const SizedBox(height: 8),
                          _kvRow('Mã hồ sơ', 'LN-XXXXXX'),
                          const SizedBox(height: 8),
                          _kvRow('Thời gian gửi', _formatNow()),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tips
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Lưu ý',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF002B5C),
                            ),
                          ),
                          SizedBox(height: 10),
                          _Bullet(
                            text:
                                'Giữ điện thoại hoạt động để nhận cuộc gọi xác minh.',
                          ),
                          _Bullet(text: 'Đảm bảo thông tin liên hệ chính xác.'),
                          _Bullet(
                            text:
                                'Nếu cần bổ sung hồ sơ, hệ thống sẽ gửi thông báo.',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),

          // BOTTOM BAR
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
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // quay về step 3
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1976D2),
                      side: const BorderSide(color: Color(0xFF1976D2)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Xem lại',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Về trang đầu (tuỳ app bạn: dashboard/home)
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Về trang chủ',
                      style: TextStyle(fontWeight: FontWeight.w600),
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

  static Widget _kvRow(String label, String value, {bool chip = false}) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        Expanded(
          flex: 7,
          child: chip
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Đang xét duyệt',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                )
              : Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF002B5C),
                  ),
                ),
        ),
      ],
    );
  }

  static String _formatNow() {
    final now = DateTime.now();
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${two(now.day)}/${two(now.month)}/${now.year} ${two(now.hour)}:${two(now.minute)}';
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black54, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
