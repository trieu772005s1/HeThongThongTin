class Installment {
  final int period;
  final String dueDate;
  final int amount;

  Installment({
    required this.period,
    required this.dueDate,
    required this.amount,
  });

  factory Installment.fromJson(Map<String, dynamic> json) {
    return Installment(
      period: json['period'] ?? 0,
      dueDate: json['dueDate'] ?? '',
      amount: json['amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'period': period,
    'dueDate': dueDate,
    'amount': amount,
  };
}

class Transaction {
  final int amount;
  final String date;

  Transaction({required this.amount, required this.date});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(amount: json['amount'] ?? 0, date: json['date'] ?? '');
  }

  Map<String, dynamic> toJson() => {'amount': amount, 'date': date};
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

  bool get isPaidOff =>
      status.toLowerCase() == 'tất toán' || status.toLowerCase() == 'paid';

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] ?? '',
      amount: json['amount'] ?? 0,
      disbursementDate: json['disbursementDate'] ?? '',
      status: json['status'] ?? '',
      paidCycles: json['paidCycles'] ?? 0,
      totalCycles: json['totalCycles'] ?? 0,
      remainingPrincipal: json['remainingPrincipal'],
      nextDueDate: json['nextDueDate'],
      installmentAmount: json['installmentAmount'],
      originalPaid: json['originalPaid'],
      closingInterest: json['closingInterest'],
      overdueAmount: json['overdueAmount'],
      closingFee: json['closingFee'],
      collectionFee: json['collectionFee'],
      transactionHistory: (json['transactionHistory'] as List? ?? [])
          .map((e) => Transaction.fromJson(e))
          .toList(),
      installments: (json['installments'] as List? ?? [])
          .map((e) => Installment.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'disbursementDate': disbursementDate,
    'status': status,
    'paidCycles': paidCycles,
    'totalCycles': totalCycles,
    'remainingPrincipal': remainingPrincipal,
    'nextDueDate': nextDueDate,
    'installmentAmount': installmentAmount,
    'originalPaid': originalPaid,
    'closingInterest': closingInterest,
    'overdueAmount': overdueAmount,
    'closingFee': closingFee,
    'collectionFee': collectionFee,
    'transactionHistory':
        transactionHistory?.map((e) => e.toJson()).toList() ?? [],
    'installments': installments?.map((e) => e.toJson()).toList() ?? [],
  };
}
