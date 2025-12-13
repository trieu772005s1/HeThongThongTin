import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Xử lý dữ liệu cá nhân",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // 👈 Nút back màu trắng
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Xử lý dữ liệu cá nhân",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "1. Mục đích thu thập dữ liệu\n"
                "- Xác minh danh tính khách hàng.\n"
                "- Thẩm định khoản vay.\n"
                "- Quản lý, theo dõi quá trình sử dụng dịch vụ.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
              SizedBox(height: 16),
              Text(
                "2. Loại dữ liệu được thu thập\n"
                "- Họ tên, ngày sinh, CCCD.\n"
                "- Số điện thoại, email, địa chỉ.\n"
                "- Lịch sử giao dịch, thông tin khoản vay.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
              SizedBox(height: 16),
              Text(
                "3. Quyền của khách hàng\n"
                "- Yêu cầu truy cập hoặc sao chép dữ liệu cá nhân.\n"
                "- Yêu cầu chỉnh sửa hoặc xoá dữ liệu.\n"
                "- Thu hồi sự đồng ý xử lý dữ liệu.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
              SizedBox(height: 16),
              Text(
                "4. Cam kết bảo mật\n"
                "- Dữ liệu được mã hoá và lưu trữ an toàn.\n"
                "- Chỉ dùng cho mục đích cung cấp dịch vụ.\n"
                "- Không chia sẻ dữ liệu với bên thứ ba nếu không có sự đồng ý.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
              SizedBox(height: 16),
              Text(
                "5. Thời hạn lưu trữ\n"
                "- Dữ liệu được lưu trữ trong suốt thời gian sử dụng dịch vụ.\n"
                "- Sau khi chấm dứt quan hệ, dữ liệu sẽ được lưu trong 5 năm theo quy định.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
