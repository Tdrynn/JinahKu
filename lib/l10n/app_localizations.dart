import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id')
  ];

  /// No description provided for @halo.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get halo;

  /// No description provided for @keuangan.
  ///
  /// In en, this message translates to:
  /// **'Manage your finances wisely'**
  String get keuangan;

  /// No description provided for @saldo.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get saldo;

  /// No description provided for @ringkasan.
  ///
  /// In en, this message translates to:
  /// **'expenditure summary'**
  String get ringkasan;

  /// No description provided for @pemasukan.
  ///
  /// In en, this message translates to:
  /// **'incoming'**
  String get pemasukan;

  /// No description provided for @pengeluaran.
  ///
  /// In en, this message translates to:
  /// **'expenditure'**
  String get pengeluaran;

  /// No description provided for @beranda.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get beranda;

  /// No description provided for @transaksi.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaksi;

  /// No description provided for @riwayat.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get riwayat;

  /// No description provided for @semua.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get semua;

  /// No description provided for @makanan.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get makanan;

  /// No description provided for @kategori.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get kategori;

  /// No description provided for @tanggal.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get tanggal;

  /// No description provided for @tanggalP.
  ///
  /// In en, this message translates to:
  /// **'Incoming Date'**
  String get tanggalP;

  /// No description provided for @namaT.
  ///
  /// In en, this message translates to:
  /// **'Transaction Name (Optional)'**
  String get namaT;

  /// No description provided for @catatan.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get catatan;

  /// No description provided for @simpan.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get simpan;

  /// No description provided for @masukan.
  ///
  /// In en, this message translates to:
  /// **'Enter your monthly income'**
  String get masukan;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Enter the total amount of money you receive per month.'**
  String get total;

  /// No description provided for @namaP.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get namaP;

  /// No description provided for @kamu.
  ///
  /// In en, this message translates to:
  /// **'Enter your user name'**
  String get kamu;

  /// No description provided for @jumlah.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get jumlah;

  /// No description provided for @sumber.
  ///
  /// In en, this message translates to:
  /// **'Source of Income'**
  String get sumber;

  /// No description provided for @pilih.
  ///
  /// In en, this message translates to:
  /// **'Select a source of income'**
  String get pilih;

  /// No description provided for @lanjutkan.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get lanjutkan;

  /// No description provided for @konfirmasi.
  ///
  /// In en, this message translates to:
  /// **'Entry Confirmation'**
  String get konfirmasi;

  /// No description provided for @pastikan.
  ///
  /// In en, this message translates to:
  /// **'Make sure the details are correct'**
  String get pastikan;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit;

  /// No description provided for @namaWajib.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get namaWajib;

  /// No description provided for @pemasukanWajib.
  ///
  /// In en, this message translates to:
  /// **'Income is required'**
  String get pemasukanWajib;

  /// No description provided for @tanggalWajib.
  ///
  /// In en, this message translates to:
  /// **'Date is required'**
  String get tanggalWajib;

  /// No description provided for @pilihK.
  ///
  /// In en, this message translates to:
  /// **'Choose Income Category'**
  String get pilihK;

  /// No description provided for @tambahD.
  ///
  /// In en, this message translates to:
  /// **'Add Description....'**
  String get tambahD;

  /// No description provided for @pilihs.
  ///
  /// In en, this message translates to:
  /// **'Choose Income Source'**
  String get pilihs;

  /// No description provided for @targerT.
  ///
  /// In en, this message translates to:
  /// **'Savings target'**
  String get targerT;

  /// No description provided for @tambahkanT.
  ///
  /// In en, this message translates to:
  /// **'add targets'**
  String get tambahkanT;

  /// No description provided for @kategoriPK.
  ///
  /// In en, this message translates to:
  /// **'Select income category'**
  String get kategoriPK;

  /// No description provided for @kategoriPN.
  ///
  /// In en, this message translates to:
  /// **'Select an expense category'**
  String get kategoriPN;

  /// No description provided for @deskripsi.
  ///
  /// In en, this message translates to:
  /// **'Add descriptions'**
  String get deskripsi;

  /// No description provided for @disimpan.
  ///
  /// In en, this message translates to:
  /// **'Transaction successfully saved! 🎉'**
  String get disimpan;

  /// No description provided for @jumlahT.
  ///
  /// In en, this message translates to:
  /// **'Transaction amount must be valid'**
  String get jumlahT;

  /// No description provided for @mohonT.
  ///
  /// In en, this message translates to:
  /// **'Please enter the transaction amount'**
  String get mohonT;

  /// No description provided for @transaksiTb.
  ///
  /// In en, this message translates to:
  /// **'Latest Transaction'**
  String get transaksiTb;

  /// No description provided for @transaksiTl.
  ///
  /// In en, this message translates to:
  /// **'Oldest Transaction'**
  String get transaksiTl;

  /// No description provided for @nominalTr.
  ///
  /// In en, this message translates to:
  /// **'Highest Amount'**
  String get nominalTr;

  /// No description provided for @nominalTh.
  ///
  /// In en, this message translates to:
  /// **'Lowest Amount'**
  String get nominalTh;

  /// No description provided for @urutkan.
  ///
  /// In en, this message translates to:
  /// **'Sort History'**
  String get urutkan;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @allowance.
  ///
  /// In en, this message translates to:
  /// **'Allowance'**
  String get allowance;

  /// No description provided for @freelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get freelance;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @goalsDescription.
  ///
  /// In en, this message translates to:
  /// **'Set a target, track your progress, and achieve your dreams.'**
  String get goalsDescription;

  /// No description provided for @createGoals.
  ///
  /// In en, this message translates to:
  /// **'Create Goals'**
  String get createGoals;

  /// No description provided for @createNewGoal.
  ///
  /// In en, this message translates to:
  /// **'Create New Goal'**
  String get createNewGoal;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @goalNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Goal name is required'**
  String get goalNameRequired;

  /// No description provided for @targetAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Target amount is required'**
  String get targetAmountRequired;

  /// No description provided for @editGoals.
  ///
  /// In en, this message translates to:
  /// **'Edit Goals'**
  String get editGoals;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @goalPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Use a photo of the item you want to buy (optional)'**
  String get goalPhotoHint;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalName;

  /// No description provided for @goalNameHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Laptop Savings'**
  String get goalNameHint;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @targetAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the target amount you want to achieve'**
  String get targetAmountHint;

  /// No description provided for @targetDate.
  ///
  /// In en, this message translates to:
  /// **'Target Date'**
  String get targetDate;

  /// No description provided for @goalNote.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get goalNote;

  /// No description provided for @goalNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Write a note or motivation for this goal...'**
  String get goalNoteHint;

  /// No description provided for @enableGoalReminder.
  ///
  /// In en, this message translates to:
  /// **'Enable goal reminders'**
  String get enableGoalReminder;

  /// No description provided for @goalReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'You\'ll receive reminders based on your schedule'**
  String get goalReminderDescription;

  /// No description provided for @minimumTarget.
  ///
  /// In en, this message translates to:
  /// **'Minimum target is Rp1,000.'**
  String get minimumTarget;

  /// No description provided for @maximumTarget.
  ///
  /// In en, this message translates to:
  /// **'Maximum target is Rp999,999,999.'**
  String get maximumTarget;

  /// No description provided for @goalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Goals updated successfully'**
  String get goalUpdated;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @saveGoals.
  ///
  /// In en, this message translates to:
  /// **'Save Goals'**
  String get saveGoals;

  /// No description provided for @goalDetail.
  ///
  /// In en, this message translates to:
  /// **'Goal Details'**
  String get goalDetail;

  /// No description provided for @completedGoalCannotBeEdited.
  ///
  /// In en, this message translates to:
  /// **'Completed goals cannot be edited'**
  String get completedGoalCannotBeEdited;

  /// No description provided for @goalOverdue.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Goal is overdue.'**
  String get goalOverdue;

  /// No description provided for @savingProgress.
  ///
  /// In en, this message translates to:
  /// **'Saving Progress'**
  String get savingProgress;

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collected;

  /// No description provided for @remainingTarget.
  ///
  /// In en, this message translates to:
  /// **'Remaining Target'**
  String get remainingTarget;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get note;

  /// No description provided for @savingHistory.
  ///
  /// In en, this message translates to:
  /// **'Saving History'**
  String get savingHistory;

  /// No description provided for @noSavingHistory.
  ///
  /// In en, this message translates to:
  /// **'No saving history yet'**
  String get noSavingHistory;

  /// No description provided for @addMoney.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get addMoney;

  /// No description provided for @showLatestTransactions.
  ///
  /// In en, this message translates to:
  /// **'Showing the latest 3 transactions'**
  String get showLatestTransactions;

  /// No description provided for @deleteGoals.
  ///
  /// In en, this message translates to:
  /// **'Delete Goals'**
  String get deleteGoals;

  /// No description provided for @currentSavedMoney.
  ///
  /// In en, this message translates to:
  /// **'Current Saved Amount'**
  String get currentSavedMoney;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @addMoneyDescription.
  ///
  /// In en, this message translates to:
  /// **'Add money to this goal'**
  String get addMoneyDescription;

  /// No description provided for @enterAmountFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount first'**
  String get enterAmountFirst;

  /// No description provided for @moneyAdded.
  ///
  /// In en, this message translates to:
  /// **'Money added successfully'**
  String get moneyAdded;

  /// No description provided for @deleteGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Goal'**
  String get deleteGoalTitle;

  /// No description provided for @deleteGoalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this goal?\n\nAll saving history will also be deleted.'**
  String get deleteGoalConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @goalDeleted.
  ///
  /// In en, this message translates to:
  /// **'Goal deleted successfully'**
  String get goalDeleted;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'id': return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
