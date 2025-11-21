import 'package:fl_credit/pages/loan_online/loan_step/steps/loan_step2_2.dart';
import 'package:fl_credit/pages/loan_online/loan_step/steps/loan_step2_3.dart';
import 'package:flutter/material.dart';
import 'loan_step2_1.dart';

class LoanStep2Page extends StatefulWidget {
  final String name;
  final String idNumber;

  const LoanStep2Page({super.key, required this.name, required this.idNumber});

  @override
  State<LoanStep2Page> createState() => _LoanStep2PageState();
}

class _LoanStep2PageState extends State<LoanStep2Page> {
  int _stepIndex = 0;

  void _next() {
    if (_stepIndex < 2) {
      setState(() {
        _stepIndex++;
      });
    } else {
      Navigator.pop(context, true); // Hoàn thành
    }
  }

  void _back() {
    if (_stepIndex > 0) {
      setState(() {
        _stepIndex--;
      });
    } else {
      Navigator.pop(context, false); // Thoát về
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget current;
    switch (_stepIndex) {
      case 0:
        current = LoanStep2_1(name: widget.name, idNumber: widget.idNumber);
        break;
      case 1:
        current = const LoanStep2_2();
        break;
      case 2:
        current = const LoanStep2_3();
        break;
      default:
        current = const SizedBox();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bước ${_stepIndex + 1}/3',
          style: const TextStyle(color: Colors.black),
        ),
        //backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_stepIndex + 1) / 3,
            minHeight: 6,
            backgroundColor: const Color.fromARGB(255, 224, 224, 224),
            color: const Color(0xFF1976D2),
          ),
          Expanded(child: current),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: _back, child: const Text('Quay lại')),
                ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                  ),
                  child: Text(
                    _stepIndex == 2 ? 'Xác nhận' : 'Tiếp tục',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
