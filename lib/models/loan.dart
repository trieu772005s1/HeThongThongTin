class Loan {
  final String id;
  final int amount; // Tổng số tiền vay
  final String disbursementDate; // Ngày giải ngân
  final String status; // Trạng thái hợp đồng
  final String? productType; // Loại sản phẩm (nếu có)

  final int paidCycles; // Kỳ đã trả
  final int totalCycles; // Tổng số kỳ

  final int? originalPaid; // Số tiền gốc đã trả
  final int? remainingPrincipal; // Tổng nợ gốc hiện tại
  final int? installmentAmount; // Số tiền kỳ tới cần thanh toán
  final String? nextDueDate; // Ngày kỳ thanh toán tiếp theo

  // Các trường cho chức năng thanh toán/đóng vay
  final int? closingInterest; // Số tiền lãi nếu đóng trước hạn
  final int? overdueAmount; // Số tiền quá hạn
  final int? closingFee; // Phí đóng khoản vay
  final int? collectionFee; // Phí thu hộ dự kiến

  final List<Transaction>? transactionHistory; // Lịch sử giao dịch

  Loan({
    required this.id,
    required this.amount,
    required this.disbursementDate,
    required this.status,
    required this.paidCycles,
    required this.totalCycles,
    this.productType,
    this.originalPaid,
    this.remainingPrincipal,
    this.installmentAmount,
    this.nextDueDate,
    this.closingInterest,
    this.overdueAmount,
    this.closingFee,
    this.collectionFee,
    this.transactionHistory,
  });
}

class Transaction {
  final String date;
  final int amount;

  Transaction({required this.date, required this.amount});
}
