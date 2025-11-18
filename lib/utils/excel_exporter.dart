import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

Future<void> exportLoanReportToExcel() async {
  final excel = Excel.createExcel();
  final Sheet sheet = excel['Báo cáo vay'];

  sheet.appendRow([
    TextCellValue('STT'),
    TextCellValue('Mã HĐ'),
    TextCellValue('Số tiền'),
    TextCellValue('Ngày giải ngân'),
    TextCellValue('Trạng thái'),
  ]);

  sheet.appendRow([
    TextCellValue('1'),
    TextCellValue('HD12345'),
    TextCellValue('5.000.000đ'),
    TextCellValue('01/11/2025'),
    TextCellValue('Đang hoạt động'),
  ]);
  sheet.appendRow([
    TextCellValue('2'),
    TextCellValue('HD67890'),
    TextCellValue('10.000.000đ'),
    TextCellValue('05/10/2025'),
    TextCellValue('Đã tất toán'),
  ]);

  final Directory dir = await getApplicationDocumentsDirectory();
  final String filePath = '${dir.path}/bao_cao_khoan_vay.xlsx';

  final List<int>? bytes = excel.encode();
  if (bytes == null) {
    return;
  }

  final File file = File(filePath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);

  print('Đã xuất file Excel tại: $filePath');
}
