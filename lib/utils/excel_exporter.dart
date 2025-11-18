import 'dart:io';
import 'package:excel/excel.dart';
import 'package:fl_credit/models/loan.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<void> exportLoanReportToExcel(List<Loan> loans) async {
  final excel = Excel.createExcel();
  final Sheet sheet = excel['Báo cáo vay'];

  final dateNow = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  sheet.appendRow([TextCellValue('BÁO CÁO DANH SÁCH KHOẢN VAY')]);
  sheet.appendRow([TextCellValue('Ngày tạo: $dateNow')]);
  sheet.appendRow([]);

  // Header
  sheet.appendRow([
    TextCellValue('STT'),
    TextCellValue('Mã HĐ'),
    TextCellValue('Số tiền'),
    TextCellValue('Ngày giải ngân'),
    TextCellValue('Trạng thái'),
  ]);

  // Dữ liệu
  for (int i = 0; i < loans.length; i++) {
    final loan = loans[i];
    sheet.appendRow([
      TextCellValue('${i + 1}'),
      TextCellValue(loan.id),
      TextCellValue('${NumberFormat('#,###', 'vi_VN').format(loan.amount)}đ'),
      TextCellValue(loan.disbursementDate),
      TextCellValue(loan.status),
    ]);
  }

  final dir = await getApplicationDocumentsDirectory();
  final filePath = '${dir.path}/bao_cao_khoan_vay.xlsx';

  final bytes = excel.encode();
  if (bytes == null) return;

  final file = File(filePath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);

  await OpenFile.open(filePath);
}
