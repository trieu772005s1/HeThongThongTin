class Installment {
  final int period;
  final String dueDate;
  final int amount;

  Installment({
    required this.period,
    required this.dueDate,
    required this.amount,
  });
}

class Transaction {
  final int amount;
  final String date;

  Transaction({required this.amount, required this.date});
}

class Loan {
  final String id;
  final int amount;
  final String disbursementDate;
  final String status;
  final int paidCycles;
  final int totalCycles;
  final int? remainingPrincipal;
  final String? nextDueDate;
  final int? installmentAmount;
  final int? originalPaid;
  final List<Transaction>? transactionHistory;
  final List<Installment>? installments;

  // Thêm các trường cần thiết cho pay_loan_page
  final int? closingInterest;
  final int? overdueAmount;
  final int? closingFee;
  final int? collectionFee;

  Loan({
    required this.id,
    required this.amount,
    required this.disbursementDate,
    required this.status,
    required this.paidCycles,
    required this.totalCycles,
    this.remainingPrincipal,
    this.nextDueDate,
    this.installmentAmount,
    this.originalPaid,
    this.transactionHistory,
    this.installments,
    this.closingInterest,
    this.overdueAmount,
    this.closingFee,
    this.collectionFee,
  });
}
