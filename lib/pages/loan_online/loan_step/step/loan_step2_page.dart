import 'package:flutter/material.dart';

class LoanStep2Page extends StatefulWidget {
  final String name;
  final String idNumber;

  const LoanStep2Page({super.key, required this.name, required this.idNumber});

  @override
  State<LoanStep2Page> createState() => _LoanStep2PageState();
}

class _LoanStep2PageState extends State<LoanStep2Page> {
  // Nếu có nhiều màn con trong bước 2 thì có thể quản lý index ở đây
  int _subPageIndex = 0;
  final int _totalSubPages = 3;

  final TextEditingController _someController = TextEditingController();

  @override
  void dispose() {
    _someController.dispose();
    super.dispose();
  }

  void _nextSubPage() {
    if (_subPageIndex < _totalSubPages - 1) {
      setState(() {
        _subPageIndex++;
      });
    } else {
      // Hoàn thành màn cuối -> trở lại trang bước chính
      Navigator.pop(context, true);
    }
  }

  void _prevSubPage() {
    if (_subPageIndex > 0) {
      setState(() {
        _subPageIndex--;
      });
    } else {
      // nếu muốn xử lý khi ở màn đầu và bấm quay lại
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_subPageIndex + 1) / _totalSubPages;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: Text(
          'Bước ${_subPageIndex + 1}/$_totalSubPages',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              color: const Color(0xFF1976D2),
              minHeight: 6,
            ),
            const SizedBox(height: 24),
            _buildTitle(),
            const SizedBox(height: 16),
            _buildContentForSubPage(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _prevSubPage,
                  child: const Text('Quay lại'),
                ),
                ElevatedButton(
                  onPressed: _nextSubPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _subPageIndex < _totalSubPages - 1
                        ? 'Tiếp tục'
                        : 'Xác nhận',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    switch (_subPageIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Khởi tạo hồ sơ vay',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Bổ sung thông tin dưới đây để chúng tôi có thể đưa ra các sản phẩm phù hợp với bạn',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        );
      case 1:
        return const Text(
          'Bạn cần vay bao nhiêu?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        );
      case 2:
        return const Text(
          'Xác nhận hồ sơ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildContentForSubPage() {
    switch (_subPageIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin cơ bản',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoCard('Họ và tên', widget.name),
            const SizedBox(height: 12),
            _buildInfoCard('Số CMND/CCCD', widget.idNumber),
            const SizedBox(height: 24),
            // Các trường khác nếu cần nhập thêm
            const SizedBox(height: 12),
            TextField(
              controller: _someController,
              decoration: const InputDecoration(
                labelText: 'Thông tin bổ sung (không bắt buộc)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 12),
            Text('Tôi mong muốn vay'),
            SizedBox(height: 8),
            Text(
              '20.000.000 VND',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.7, // chỉ demo
              minHeight: 4,
            ),
            SizedBox(height: 16),
            Text('Thời gian cấp hạn mức: 36 tháng'),
            SizedBox(height: 24),
            Text('Mục đích vay'),
            // Dropdown hoặc chọn mục đích ở đây
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Vui lòng kiểm tra lại thông tin và xác nhận gửi hồ sơ',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            // Có thể hiện tóm tắt thông tin
            Text('Họ và tên: Biện Phúc Toàn'),
            SizedBox(height: 8),
            Text('Số CMND/CCCD: 079205003635'),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
