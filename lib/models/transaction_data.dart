class TransactionData {
  final double amount;
  final DateTime date;
  final String? merchant;

  TransactionData({
    required this.amount,
    required this.date,
    required this.merchant,
  });

  factory TransactionData.empty() {
    return TransactionData(
      amount: 0.0,
      merchant: null,
      date: DateTime.now(),
    );
  }
}