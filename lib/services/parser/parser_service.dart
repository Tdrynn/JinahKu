import 'DigitalReciptParser.dart';
import 'StoreReciptParser.dart';
import 'package:jinahku/models/transaction_result.dart';

class ParserService {
  static TransactionResult parse(String text) {
    final upper = text.toUpperCase();

    if (upper.contains("ALFAMART") || upper.contains("NPWP")) {
      print("STORE RECEIPT DETECTED");
      return StoreReceiptParser.parse(text);
    }

    print("DIGITAL RECEIPT DETECTED");
    return DigitalReceiptParser.parse(text);
  }
}
