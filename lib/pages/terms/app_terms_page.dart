import 'package:flutter/material.dart';

class AppTermsPage extends StatelessWidget {
  const AppTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Điều khoản & Điều kiện sử dụng",
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
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Điều khoản & Điều kiện sử dụng",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _section(
                    "1. Chấp nhận điều khoản",
                    [
                      "Khi sử dụng ứng dụng, bạn đồng ý tuân thủ toàn bộ điều khoản dưới đây.",
                      "Nếu không đồng ý, vui lòng ngừng sử dụng ứng dụng.",
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    "2. Quyền sử dụng ứng dụng",
                    [
                      "Bạn được phép sử dụng ứng dụng cho mục đích cá nhân.",
                      "Không sao chép, chỉnh sửa hoặc phân phối lại ứng dụng khi chưa được phép.",
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    "3. Quyền riêng tư & bảo mật",
                    [
                      "Ứng dụng thu thập thông tin cá nhân theo chính sách bảo mật.",
                      "FE Credit cam kết bảo mật thông tin khách hàng.",
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    "4. Trách nhiệm của người dùng",
                    [
                      "Cung cấp thông tin chính xác khi sử dụng dịch vụ.",
                      "Không sử dụng ứng dụng cho các hoạt động bất hợp pháp.",
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    "5. Giới hạn trách nhiệm",
                    [
                      "FE Credit không chịu trách nhiệm về lỗi thiết bị, mạng hoặc lỗi phát sinh ngoài phạm vi kiểm soát.",
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    "6. Thay đổi điều khoản",
                    [
                      "Các điều khoản có thể được cập nhật bất cứ lúc nào.",
                      "Chúng tôi sẽ thông báo khi có thay đổi quan trọng.",
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

  // Component hiển thị từng mục
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
