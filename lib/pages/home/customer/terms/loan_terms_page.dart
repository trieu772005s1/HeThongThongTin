import 'package:flutter/material.dart';

class LoanTermsPage extends StatelessWidget {
  const LoanTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Điều khoản cho vay",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Điều khoản cho vay",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              Text(
                "1. Mục đích sử dụng khoản vay\n"
                "- Khách hàng cam kết sử dụng khoản vay đúng mục đích đã khai báo.\n"
                "- FE Credit có quyền kiểm tra, xác minh mục đích sử dụng khoản vay.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),

              SizedBox(height: 16),

              Text(
                "2. Lãi suất & phí\n"
                "- Lãi suất tính theo dư nợ giảm dần.\n"
                "- Các loại phí bao gồm: phí tư vấn, phí thu hộ, phí chậm thanh toán.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),

              SizedBox(height: 16),

              Text(
                "3. Nghĩa vụ thanh toán\n"
                "- Khách hàng thanh toán đúng kỳ hạn.\n"
                "- Các khoản trễ hạn sẽ bị tính thêm phí và lãi phạt.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),

              SizedBox(height: 16),

              Text(
                "4. Quyền & nghĩa vụ các bên\n"
                "- FE Credit có quyền thu hồi nợ theo quy định.\n"
                "- Khách hàng có quyền yêu cầu cung cấp thông tin minh bạch.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),

              SizedBox(height: 16),

              Text(
                "5. Bảo mật thông tin\n"
                "- Thông tin khách hàng được bảo mật theo luật định.\n"
                "- FE Credit chỉ sử dụng thông tin cho mục đích thẩm định và quản lý khoản vay.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),

              SizedBox(height: 16),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
