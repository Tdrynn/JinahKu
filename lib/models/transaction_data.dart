class TransactionData {
  final double amount;
  final DateTime date;
  final String type;
  final String categoryCode;
  final String? note;

  TransactionData({
    required this.amount,
    required this.date,
    required this.type,
    required this.categoryCode,
    this.note,
  });

  factory TransactionData.empty() {
    return TransactionData(
      amount: 0,
      date: DateTime.now(),
      type: 'expense',
      categoryCode: '',
      note: null,
    );
  }
}
