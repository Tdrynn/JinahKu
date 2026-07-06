import 'package:flutter/material.dart';
import 'package:jinahku/pages/transaction.dart';
import 'homepage.dart';
import 'history.dart';
import 'package:jinahku/widgets/navbar.dart';
import 'package:share_handler/share_handler.dart';
import 'package:jinahku/services/share_service.dart';
import 'package:jinahku/services/ocr_service.dart';
import 'package:jinahku/services/parser/parser_service.dart';
import 'package:jinahku/models/transaction_data.dart';

class MainPage extends StatefulWidget {
  final bool isDark;
  final bool isEnglish;
  final Function(bool) onToggleTheme;
  final Function(String) onChangeLanguage;
  final VoidCallback restartOnBoarding;

  const MainPage({
    super.key,
    required this.isDark,
    required this.isEnglish,
    required this.onToggleTheme,
    required this.onChangeLanguage,
    required this.restartOnBoarding,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  TransactionData? importedTransaction;

  final GlobalKey<HomePageState> homeKey = GlobalKey<HomePageState>();

  Future<void> listenShare() async {
    ShareService.startListening((media) async {
      await processSharedMedia(media);
    });

    final media = await ShareService.getInitialMedia();

    if (media != null) {
      await processSharedMedia(media);
    }
  }

  Future<void> processSharedMedia(SharedMedia media) async {
    final attachments = media.attachments;

    if (attachments == null || attachments.isEmpty) return;

    final imagePath = attachments.first?.path;

    if (imagePath == null) return;

    final text = await OcrService.readText(imagePath);

    final result = ParserService.parse(text);

    if (!mounted) return;

    setState(() {
      importedTransaction = TransactionData(
        amount: result.amount?.toDouble() ?? 0,
        date: result.date ?? DateTime.now(),
        type: 'expense',
        categoryCode: '',
        note: result.merchant,
      );

      selectedIndex = 2;
    });
  }

  @override
  void initState() {
    super.initState();
    listenShare();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        key: homeKey,
        isDark: widget.isDark,
        isEnglish: widget.isEnglish,
        onToggleTheme: widget.onToggleTheme,
        onChangeLanguage: widget.onChangeLanguage,
        restartOnBoarding: widget.restartOnBoarding,
      ),

      History(isDark: widget.isDark),

      Transaction(
        isDark: widget.isDark,
        initialData: importedTransaction,
        onTransactionSaved: () async {
          await homeKey.currentState?.refreshData();

          setState(() {
            selectedIndex = 0;
          });
        },
      ),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: widget.isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: Navbar(
        selectedIndex: selectedIndex,
        isDark: widget.isDark,
        isEnglish: widget.isEnglish,
        onToggleTheme: widget.onToggleTheme,
        onChangeLanguage: widget.onChangeLanguage,
        onItemTapped: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
