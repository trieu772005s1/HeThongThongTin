import 'package:flutter/material.dart';

import 'package:fl_credit/models/reward.dart';
import 'package:fl_credit/models/voucher.dart';
import 'package:fl_credit/services/wardrobe_service.dart';

class AdminUserBenefitPage extends StatelessWidget {
  final String userId;
  final String userName;

  AdminUserBenefitPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  final WardrobeService service = WardrobeService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Quà & Voucher - $userName'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Phần quà'),
              Tab(text: 'Voucher'),
            ],
          ),
        ),

        floatingActionButton: _buildFab(context),

        body: TabBarView(children: [_buildRewardTab(), _buildVoucherTab()]),
      ),
    );
  }

  // =============================
  // TAB PHẦN QUÀ
  // =============================
  Widget _buildRewardTab() {
    return StreamBuilder<List<Reward>>(
      stream: service.getRewards(userId),
      builder: (_, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final list = snapshot.data!;
        if (list.isEmpty) return const Center(child: Text('Chưa có phần quà'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final r = list[i];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: _box,
              child: Row(
                children: [
                  Text(r.icon, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(r.description),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => service.deleteReward(userId, r.id),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // =============================
  // TAB VOUCHER
  // =============================
  Widget _buildVoucherTab() {
    return StreamBuilder<List<Voucher>>(
      stream: service.getVouchers(userId),
      builder: (_, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final list = snapshot.data!;
        if (list.isEmpty) return const Center(child: Text('Chưa có voucher'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final v = list[i];
            final expiredText = v.expiredAt.toString().split(' ').first;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: _box,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("Mã: ${v.code}"),
                  Text("Giảm: ${v.discount}%"),
                  Text(
                    "Hết hạn: $expiredText",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => service.deleteVoucher(userId, v.id),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // =============================
  // NÚT FAB — TỰ ĐỔI THEO TAB
  // =============================
  Widget _buildFab(BuildContext context) {
    return Builder(
      builder: (context) {
        final tabController = DefaultTabController.of(context);

        return AnimatedBuilder(
          animation: tabController,
          builder: (context, _) {
            final index = tabController.index;

            return FloatingActionButton.extended(
              onPressed: () {
                if (index == 0) {
                  _showAddRewardDialog(context);
                } else {
                  _showAddVoucherDialog(context);
                }
              },
              label: Text(index == 0 ? 'Thêm phần quà' : 'Thêm voucher'),
              icon: const Icon(Icons.add),
            );
          },
        );
      },
    );
  }

  // =============================
  // POPUP THÊM PHẦN QUÀ
  // =============================
  Future<void> _showAddRewardDialog(BuildContext context) async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final iconCtrl = TextEditingController(text: "🎁");

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm phần quà'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            TextField(
              controller: iconCtrl,
              decoration: const InputDecoration(labelText: 'Icon (emoji)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await service.addReward(
                userId,
                Reward(
                  id: '',
                  title: titleCtrl.text,
                  description: descCtrl.text,
                  icon: iconCtrl.text,
                  createdAt: DateTime.now(),
                ),
              );

              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // =============================
  // POPUP THÊM VOUCHER
  // =============================
  Future<void> _showAddVoucherDialog(BuildContext context) async {
    final titleCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final discountCtrl = TextEditingController(text: '10');
    DateTime expiredAt = DateTime.now().add(const Duration(days: 30));

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setStateDialog) => AlertDialog(
          title: const Text('Thêm voucher'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
              ),
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Mã voucher'),
              ),
              TextField(
                controller: discountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giảm (%)'),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: expiredAt,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setStateDialog(() => expiredAt = picked);
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Text("Hết hạn: ${expiredAt.toString().split(' ').first}"),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                await service.addVoucher(
                  userId,
                  Voucher(
                    id: '',
                    title: titleCtrl.text,
                    code: codeCtrl.text,
                    discount: int.parse(discountCtrl.text),
                    expiredAt: expiredAt,
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // BOX STYLE
  // =============================
  BoxDecoration get _box => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.05),
        blurRadius: 6,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
