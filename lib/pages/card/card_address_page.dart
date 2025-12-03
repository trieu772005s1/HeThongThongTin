import 'package:flutter/material.dart';
import 'card_financial_page.dart';

class CardAddressPage extends StatefulWidget {
  final double limit;
  final String email;

  const CardAddressPage({super.key, required this.limit, required this.email});

  @override
  State<CardAddressPage> createState() => _CardAddressPageState();
}

class _CardAddressPageState extends State<CardAddressPage> {
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;

  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                widthFactor: 0.60, // bước 4 ~ 60%
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "Địa chỉ hiện tại của bạn ở đâu?",
              style: TextStyle(
                fontSize: 26,
                color: Color(0xFF002C5F),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // Province
            const Text(
              "Tỉnh/Thành phố",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),

            _buildDropdown(
              hint: "Chọn",
              value: selectedProvince,
              onChanged: (v) => setState(() => selectedProvince = v),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Quận/Huyện",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildDropdown(
                        hint: "Chọn",
                        value: selectedDistrict,
                        onChanged: (v) => setState(() => selectedDistrict = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Phường/Xã",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildDropdown(
                        hint: "Chọn",
                        value: selectedWard,
                        onChanged: (v) => setState(() => selectedWard = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Text(
              "Địa chỉ chính xác",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 6),

            TextField(
              controller: addressController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Nhập đầy đủ số nhà, đường...",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ),

            const Spacer(),

            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CardFinancialPage(
                        limit: widget.limit.toInt(),
                        email: widget.email,
                        addressData: {
                          "province": selectedProvince ?? "",
                          "district": selectedDistrict ?? "",
                          "ward": selectedWard ?? "",
                          "fullAddress": addressController.text.trim(),
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1976D2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Tiếp theo",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: [
            "TP.HCM",
            "Hà Nội",
            "Đà Nẵng",
            "Cần Thơ",
            "Khánh Hòa",
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
