import 'package:flutter/foundation.dart';
import 'package:jinahku/models/transaction_result.dart';

class StoreReceiptParser {
  static TransactionResult parse(String text) {
    final amount = _parseAmount(text);
    final merchant = _parseMerchant(text);
    final date = _parseDate(text);

    debugPrint("===== STORE PARSER =====");
    debugPrint("Amount   : $amount");
    debugPrint("Merchant : $merchant");
    debugPrint("Date     : $date");

    return TransactionResult(amount: amount, merchant: merchant, date: date);
  }

  // mengambil nominal
  static int? _parseAmount(String text) {
    final lines = text.split("\n");

    List<int> candidates = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();

      if (line.contains("total") ||
          line.contains("tunai") ||
          line.contains("grand total")) {
        for (int j = i + 1; j < lines.length && j <= i + 8; j++) {
          if (RegExp(r'\d{2}-\d{2}-\d{4}').hasMatch(lines[j])) {
            continue;
          }
          final value = lines[j].replaceAll(RegExp(r'[^0-9]'), '');

          if (value.isEmpty) continue;

          final amount = int.tryParse(value);

          if (amount != null && amount >= 1000) {
            candidates.add(amount);
          }
        }
      }
    }

    if (candidates.isEmpty) return null;
    candidates.sort();
    return candidates.last;
  }

  // mengambil nama toko
  static String? _parseMerchant(String text) {
    final lines = text.split("\n");

    if (lines.isEmpty) return null;

    return lines.first.trim();
  }

  // mengambil tanggal
  static DateTime? _parseDate(String text) {
    final regex = RegExp(r'(\d{2})-(\d{2})-(\d{4})');

    final match = regex.firstMatch(text);

    if (match == null) return null;

    return DateTime(
      int.parse(match.group(3)!),
      int.parse(match.group(2)!),
      int.parse(match.group(1)!),
    );
  }
}
