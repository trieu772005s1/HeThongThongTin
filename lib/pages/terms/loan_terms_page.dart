import 'package:flutter/material.dart';

class LoanTermsPage extends StatelessWidget {
  const LoanTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Điều khoản cho vay",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Điều khoản cho vay",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _section(
                    "1. Mục đích sử dụng khoản vay",
                    [
                      "Khách hàng cam kết sử dụng khoản vay đúng mục đích đã khai báo.",
                      "FE Credit có quyền kiểm tra, xác minh mục đích sử dụng khoản vay.",
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    "2. Lãi suất & phí",
                    [
                      "Lãi suất tính theo dư nợ giảm dần.",
                      "Các loại phí bao gồm: phí tư vấn, phí thu hộ, phí chậm thanh toán.",
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    "3. Nghĩa vụ thanh toán",
                    [
                      "Khách hàng thanh toán đúng kỳ hạn.",
                      "Các khoản trễ hạn sẽ bị tính thêm phí và lãi phạt.",
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    "4. Quyền & nghĩa vụ các bên",
                    [
                      "FE Credit có quyền thu hồi nợ theo quy định.",
                      "Khách hàng có quyền yêu cầu cung cấp thông tin minh bạch.",
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    "5. Bảo mật thông tin",
                    [
                      "Thông tin khách hàng được bảo mật theo luật định.",
                      "FE Credit chỉ sử dụng thông tin cho mục đích thẩm định và quản lý khoản vay.",
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------
  // Component từng mục
  // --------------------------
  Widget _section(String title, List<String> bullets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        ...bullets.map(
          (e) => Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              "- $e",
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
