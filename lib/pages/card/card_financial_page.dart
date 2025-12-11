import 'package:flutter/material.dart';
import 'card_confirm_page.dart';

class CardFinancialPage extends StatefulWidget {
  final int limit; // Hạn mức đã chọn
  final String email; // Email đã nhập
  final Map<String, dynamic>
  addressData; // Dữ liệu địa chỉ (tỉnh, huyện, xã, ...)

  const CardFinancialPage({
    super.key,
    required this.limit,
    required this.email,
    required this.addressData,
  });

  @override
  State<CardFinancialPage> createState() => _CardFinancialPageState();
}

class _CardFinancialPageState extends State<CardFinancialPage> {
  String? selectedOption;

  final List<String> options = [
    "Hóa đơn điện",
    "Cán bộ công chức nhà nước",
    "Theo hợp đồng bảo hiểm nhân thọ",
    "Sử dụng thuê bao di động Vinaphone, Mobiphone, Viettel",
    "Chứng minh thu nhập từ lương",
    "Hóa đơn tiện ích (nước, truyền hình cáp, internet)",
    "Mở theo số dư tài khoản ngân hàng",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hình thức chứng minh tài chính"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chọn 1 trong các phương án dưới đây",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final item = options[index];
                  return RadioListTile<String>(
                    title: Text(item),
                    value: item,
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() => selectedOption = value);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedOption == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CardConfirmPage(
                              limit: widget.limit,
                              email: widget.email,
                              province: widget.addressData["province"],
                              district: widget.addressData["district"],
                              ward: widget.addressData["ward"],
                              fullAddress: widget.addressData["fullAddress"],
                              financialMethod: selectedOption!,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedOption == null
                      ? Colors.grey.shade400
                      : Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Tiếp theo", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
