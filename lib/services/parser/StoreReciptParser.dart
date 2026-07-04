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
      final line = lines[i];
      final lower = line.toLowerCase();

      if (lower.contains("total") && !lower.contains("subtotal")) {
        final sameLineValue = _extractAmountFromLine(line);
        if (sameLineValue != null) {
          candidates.add(sameLineValue);
          continue;
        }

        for (int j = i + 1; j < lines.length && j <= i + 8; j++) {
          if (RegExp(r'\d{1,2}[-.]\d{1,2}[-.]\d{2,4}').hasMatch(lines[j])) {
            continue;
          }
          final value = _extractAmountFromLine(lines[j]);
          if (value != null) {
            candidates.add(value);
            break;
          }
        }
      }
    }

    if (candidates.isEmpty) return null;
    candidates.sort();
    return candidates.last;
  }

  static int? _extractAmountFromLine(String line) {
    final relevant = line.contains(':') ? line.split(':').last : line;

    final digits = relevant.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;

    final amount = int.tryParse(digits);
    if (amount != null && amount >= 1000) return amount;
    return null;
  }

  static String? _parseMerchant(String text) {
    final upper = text.toUpperCase();

    const knownMerchants = [
      'INDOMARET',
      'ALFAMART',
      'ALFAMIDI',
      'CIRCLE K',
      'LAWSON',
    ];

    for (final name in knownMerchants) {
      if (upper.contains(name)) return name;
    }

    final lines = text
        .split("\n")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (lines.isEmpty) return null;
    return lines.first;
  }

  // mengambil tanggal
  static DateTime? _parseDate(String text) {
    final regexDash = RegExp(r'(\d{2})-(\d{2})-(\d{4})');
    final matchDash = regexDash.firstMatch(text);
    if (matchDash != null) {
      return DateTime(
        int.parse(matchDash.group(3)!),
        int.parse(matchDash.group(2)!),
        int.parse(matchDash.group(1)!),
      );
    }

    final regexDot = RegExp(r'(\d{2})\.(\d{2})\.(\d{2})\b');
    final matchDot = regexDot.firstMatch(text);
    if (matchDot != null) {
      final year = 2000 + int.parse(matchDot.group(3)!);
      return DateTime(
        year,
        int.parse(matchDot.group(2)!),
        int.parse(matchDot.group(1)!),
      );
    }

    return null;
  }
}