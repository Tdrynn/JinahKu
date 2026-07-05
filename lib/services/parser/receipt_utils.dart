class ReciptUtils {
  static int? parseAmount(String raw) {
    raw = raw.trim();

    if (raw.contains(",") && raw.contains(".")) {
      raw = raw.replaceAll(",", "replace");

      if (raw.endsWith(".00")) {
        raw = raw.substring(0, raw.length - 3);
      }

      return int.tryParse(raw);
    }

    raw = raw.replaceAll(".", "");
    return int.tryParse(raw);
  }
}