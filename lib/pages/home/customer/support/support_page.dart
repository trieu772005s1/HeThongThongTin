import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> openZalo() async {
  final url = Uri.parse("https://zalo.me/0962392122"); // ID OA hoặc link chat Zalo
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception("Không mở được Zalo");
  }
}
Future<void> openFacebook() async {
  const fbPageId = "100008663516592";  // ID Fanpage thật (VD: 100083829281726)
  final fbUrlApp = Uri.parse("fb://profile/$fbPageId");

  // Thử mở app trước
  if (await canLaunchUrl(fbUrlApp)) {
    await launchUrl(fbUrlApp, mode: LaunchMode.externalApplication);
    return;
  }


 
}
Future<void> callHotline() async {
  final uri = Uri(scheme: 'tel', path: '19001009');
  if (!await launchUrl(uri)) {
    throw Exception('Không gọi được số điện thoại');
  }
}
Future<void> sendEmail() async {
  final uri = Uri(
    scheme: 'mailto',
    path: 'support@myapp.com',
    query: 'subject=Hỗ trợ khách hàng&body=Tôi cần hỗ trợ...',
  );

  if (!await launchUrl(uri)) {
    throw Exception('Không mở được ứng dụng Email');
  }
}

    return Scaffold(
      backgroundColor: const Color(0xFF1976D2), // BLUE BACKGROUND
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        iconTheme: const IconThemeData(
      color: Colors.white,  // 👉 arrow trắng
       ),
        title: const Text(
          'Hỗ trợ',
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // Ảnh cầm tiền
          SizedBox(
            height: 180,
            child: Center(
              child: Image.asset(
                'assets/images/loan_step_page_background.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Khối trắng bo góc
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  const Text(
                    'Kênh hỗ trợ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildSupportItem(
                    icon: Icons.chat,
                    iconColor: Colors.blue,
                    title: 'Zalo',
                    subtitle: 'Nhắn tin qua Zalo CSKH',
                   onTap: () => openZalo(),

                  ),

                  _buildSupportItem(
                    icon: Icons.facebook,
                    iconColor: Colors.indigo,
                    title: 'Facebook',
                    subtitle: 'Fanpage hỗ trợ khách hàng',
                    onTap: () => openFacebook(),

                  ),

                  _buildSupportItem(
                    icon: Icons.phone,
                    iconColor: Colors.green,
                    title: 'Hotline',
                    subtitle: 'Gọi tổng đài chăm sóc khách hàng',
                    onTap: () => callHotline(),
                  ),

                  _buildSupportItem(
                    icon: Icons.email,
                    iconColor: Colors.deepOrange,
                    title: 'Email',
                    subtitle: 'Gửi email hỗ trợ',
                    onTap: () => sendEmail(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: iconColor.withOpacity(0.08),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
