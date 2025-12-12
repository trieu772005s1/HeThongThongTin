import 'package:flutter/material.dart';

class AppTermsPage extends StatelessWidget {
  const AppTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Điều khoản & Điều kiện sử dụng"),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Điều khoản & Điều kiện sử dụng",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              Text(
                "1. Chấp nhận điều khoản\n"
                "Khi sử dụng ứng dụng, bạn đồng ý tuân thủ toàn bộ điều khoản dưới đây. "
                "Nếu không đồng ý, vui lòng ngừng sử dụng ứng dụng.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),

              SizedBox(height: 16),

              Text(
                "2. Quyền sử dụng ứng dụng\n"
                "- Bạn được phép sử dụng ứng dụng cho mục đích cá nhân.\n"
                "- Không sao chép, chỉnh sửa hoặc phân phối lại ứng dụng khi chưa được phép.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),

              SizedBox(height: 16),

              Text(
                "3. Quyền riêng tư & bảo mật\n"
                "- Ứng dụng thu thập thông tin cá nhân theo chính sách bảo mật.\n"
                "- FE Credit cam kết bảo mật thông tin khách hàng.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),

              SizedBox(height: 16),

              Text(
                "4. Trách nhiệm của người dùng\n"
                "- Cung cấp thông tin chính xác khi sử dụng dịch vụ.\n"
                "- Không sử dụng ứng dụng cho các hoạt động bất hợp pháp.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),

              SizedBox(height: 16),

              Text(
                "5. Giới hạn trách nhiệm\n"
                "- FE Credit không chịu trách nhiệm về lỗi thiết bị, mạng hoặc lỗi phát sinh ngoài phạm vi kiểm soát.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),

              SizedBox(height: 16),

              Text(
                "6. Thay đổi điều khoản\n"
                "Các điều khoản có thể được cập nhật bất cứ lúc nào. "
                "Chúng tôi sẽ thông báo khi có thay đổi quan trọng.",
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
