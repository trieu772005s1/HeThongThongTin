import 'package:flutter/material.dart';
import 'package:fl_credit/pages/loan_online/loan_step/loan_step_page.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: const Text(
          'Xin chào!\nBiện Phúc Toàn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {},
              ),
              const Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(backgroundColor: Colors.red, radius: 4),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBanner(context),
          const SizedBox(height: 24),
          _buildFunctionItems(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.card_giftcard, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Mở khoản vay\nNhận tiền liền tay',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ưu đãi mỗi ngày từ Mcredit',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showLoanBottomSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Vay ngay',
              style: TextStyle(
                color: Color(0xFF1976D2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================
  // BOTTOM SHEET - CHỌN SẢN PHẨM
  // ==============================
  void _showLoanBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chọn sản phẩm vay',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mcredit cung cấp các sản phẩm phù hợp giúp bạn dễ dàng vay tiền nhất',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // VAY ONLINE
              ListTile(
                leading: const Icon(Icons.monetization_on, color: Colors.blue),
                title: const Text('Vay Online'),
                subtitle: const Text('Khoản vay tới 100.000.000 VND'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoanStepPage()),
                  );
                },
              ),
              const Divider(),

              // TƯ VẤN
              ListTile(
                leading: const Icon(Icons.support_agent, color: Colors.blue),
                title: const Text('Đăng ký nhận tư vấn vay'),
                subtitle: const Text('Nghe tư vấn miễn phí từ chuyên viên'),
                onTap: () => Navigator.pop(context),
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ==============================
  // GRID MENU
  // ==============================
  Widget _buildFunctionItems(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildFuncItem(Icons.monetization_on, 'Vay Online', () {
          _showLoanBottomSheet(context);
        }),
        _buildFuncItem(Icons.shopping_bag, 'Tủ đồ', () {}),
        _buildFuncItem(Icons.location_on, 'Điểm giao dịch', () {}),
        _buildFuncItem(Icons.support_agent, 'Hỗ trợ', () {}),
      ],
    );
  }

  Widget _buildFuncItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: Colors.blue.shade800),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
