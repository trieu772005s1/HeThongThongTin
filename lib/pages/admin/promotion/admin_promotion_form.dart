import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/promotion.dart';

class AdminPromotionForm extends StatefulWidget {
  final Promotion? editData;

  AdminPromotionForm({super.key, this.editData}); // KHÔNG dùng const

  @override
  State<AdminPromotionForm> createState() => _AdminPromotionFormState();
}

class _AdminPromotionFormState extends State<AdminPromotionForm> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  DateTime? startAt;
  DateTime? endAt;

  @override
  void initState() {
    super.initState();

    if (widget.editData != null) {
      titleCtrl.text = widget.editData!.title;
      descCtrl.text = widget.editData!.description;
      startAt = widget.editData!.startAt;
      endAt = widget.editData!.endAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editData != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Chỉnh sửa ưu đãi" : "Thêm ưu đãi"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _input("Tiêu đề", titleCtrl),
          const SizedBox(height: 12),
          _input("Mô tả", descCtrl, maxLines: 3),

          const SizedBox(height: 16),
          _datePicker("Ngày bắt đầu", startAt, (v) => setState(() => startAt = v)),
          const SizedBox(height: 12),
          _datePicker("Ngày kết thúc", endAt, (v) => setState(() => endAt = v)),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _save,
            child: Text(isEdit ? "Cập nhật" : "Lưu"),
          ),
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _datePicker(
    String label,
    DateTime? value,
    Function(DateTime) onSelect,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onSelect(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          value == null
              ? "$label (chưa chọn)"
              : "$label: ${value.toString().split(' ').first}",
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (titleCtrl.text.isEmpty ||
        descCtrl.text.isEmpty ||
        startAt == null ||
        endAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Điền đủ thông tin")),
      );
      return;
    }

    final data = {
      "title": titleCtrl.text,
      "description": descCtrl.text,
      "startAt": startAt!,
      "endAt": endAt!,
    };

    final promotions = FirebaseFirestore.instance.collection("promotions");

    if (widget.editData == null) {
      await promotions.add(data); // thêm mới
    } else {
      await promotions.doc(widget.editData!.id).update(data); // cập nhật
    }

    Navigator.pop(context);
  }
}
