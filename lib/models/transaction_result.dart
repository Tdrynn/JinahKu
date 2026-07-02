class TransactionResult {
  final int? amount;
  final String? merchant;
  final DateTime? date;

  const TransactionResult({
    this.amount,
    this.merchant,
    this.date,
  });

  factory TransactionResult.empty() {
    return TransactionResult(
      amount: 0,
      merchant: null,
      date: DateTime.now(),
    );
  }
}