// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get halo => 'Hello 👋';

  @override
  String get keuangan => 'Manage your finances wisely';

  @override
  String get saldo => 'Current balance';

  @override
  String get ringkasan => 'This month\'s summary';

  @override
  String get pemasukan => 'incoming';

  @override
  String get pengeluaran => 'expenditure';

  @override
  String get beranda => 'Home';

  @override
  String get transaksi => 'Transaction';

  @override
  String get riwayat => 'History';

  @override
  String get semua => 'All';

  @override
  String get makanan => 'Food';

  @override
  String get kategori => 'Category';

  @override
  String get tanggal => 'Date';

  @override
  String get namaT => 'Transaction Name (Optional)';

  @override
  String get catatan => 'Notes (Optional)';

  @override
  String get simpan => 'Save';
}
