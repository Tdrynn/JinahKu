import 'package:flutter/foundation.dart';
import 'package:jinahku/models/transaction_result.dart';

class DigitalReceiptParser {
  static TransactionResult parse(String text) {
    final amount = _parseAmount(text);
    final merchant = _parseMerchant(text);
    final date = _parseDate(text);

    debugPrint("===== DIGITAL PARSER =====");
    debugPrint("Amount   : $amount");
    debugPrint("Merchant : $merchant");
    debugPrint("Date     : $date");

    return TransactionResult(
      amount: amount,
      merchant: merchant,
      date: date,
    );
  }

  // Mengambil nominal
  static int? _parseAmount(String text) {
    final amountRegex = RegExp(
      r'(?:Rp|IDR)\.?\s*([\d.,]+)',
      caseSensitive: false,
    );

    final matches = amountRegex.allMatches(text);

    int? biggestAmount;

    for (final match in matches) {
      String? raw = match.group(1);

      if (raw == null) continue;

      String value = raw.trim();

      if (value.contains(",") && value.contains(".")) {
        value = value.replaceAll(",", "");

        if (value.endsWith(".00")) {
          value = value.substring(0, value.length - 3);
        }
      } else {
        value = value.replaceAll(".", "");
      }

      final nominal = int.tryParse(value);

      if (nominal == null) continue;

      if (biggestAmount == null || nominal > biggestAmount) {
        biggestAmount = nominal;
      }
    }

    return biggestAmount;
  }

  // Mengambil merchant
  static String? _parseMerchant(String text) {
    final merchantRegex = RegExp(
      r'GoPay|Tokopedia|BCA|Livin|DANA|Shopee',
      caseSensitive: false,
    );

    final match = merchantRegex.firstMatch(text);

    if (match != null) {
      return match.group(0);
    }

    return null;
  }

  // Mengambil tanggal
  static DateTime? _parseDate(String text) {
    final monthMap = {
      "Jan": 1,
      "Feb": 2,
      "Mar": 3,
      "Apr": 4,
      "May": 5,
      "Mei": 5,
      "Jun": 6,
      "Jul": 7,
      "Aug": 8,
      "Agu": 8,
      "Sep": 9,
      "Oct": 10,
      "Okt": 10,
      "Nov": 11,
      "Dec": 12,
      "Des": 12,
    };

    final regex1 = RegExp(
      r'(\d{1,2})\s([A-Za-z]{3})\s(\d{4})',
    );

    final match1 = regex1.firstMatch(text);

    if (match1 != null) {
      final month = monthMap[match1.group(2)];

      if (month != null) {
        return DateTime(
          int.parse(match1.group(3)!),
          month,
          int.parse(match1.group(1)!),
        );
      }
    }

    final regex2 = RegExp(
      r'(\d{2})-(\d{2})-(\d{4})',
    );

    final match2 = regex2.firstMatch(text);

    if (match2 != null) {
      return DateTime(
        int.parse(match2.group(3)!),
        int.parse(match2.group(2)!),
        int.parse(match2.group(1)!),
      );
    }

    final regex3 = RegExp(
      r'(\d{2})\/(\d{2})\/(\d{4})',
    );

    final match3 = regex3.firstMatch(text);

    if (match3 != null) {
      return DateTime(
        int.parse(match3.group(3)!),
        int.parse(match3.group(2)!),
        int.parse(match3.group(1)!),
      );
    }

    return null;
  }
}