import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f6fb),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Xử lý dữ liệu cá nhân",
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
            constraints: const BoxConstraints(maxWidth: 600), // GIỚI HẠN ĐỘ RỘNG
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
                  // ----- TITLE ------
                  const Text(
                    "Xử lý dữ liệu cá nhân",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _section(
                    "1. Mục đích thu thập dữ liệu",
                    [
                      "Xác minh danh tính khách hàng.",
                      "Thẩm định khoản vay.",
                      "Quản lý và theo dõi quá trình sử dụng dịch vụ.",
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    "2. Loại dữ liệu được thu thập",
                    [
                      "Họ tên, ngày sinh, CCCD.",
                      "Số điện thoại, email, địa chỉ.",
                      "Lịch sử giao dịch và thông tin khoản vay.",
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    "3. Quyền của khách hàng",
                    [
                      "Yêu cầu truy cập hoặc sao chép dữ liệu cá nhân.",
                      "Yêu cầu chỉnh sửa hoặc xoá dữ liệu.",
                      "Thu hồi sự đồng ý xử lý dữ liệu.",
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    "4. Cam kết bảo mật",
                    [
                      "Dữ liệu được mã hoá và lưu trữ an toàn.",
                      "Chỉ dùng để cung cấp và vận hành dịch vụ.",
                      "Không chia sẻ cho bên thứ ba nếu không có sự đồng ý.",
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    "5. Thời hạn lưu trữ",
                    [
                      "Dữ liệu được lưu trong suốt thời gian sử dụng dịch vụ.",
                      "Sau khi kết thúc quan hệ, dữ liệu được lưu 5 năm theo quy định.",
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------
  // WIDGET HIỂN THỊ TỪNG MỤC
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
