import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jinahku/l10n/app_localizations.dart';

import '../database/db_helper.dart';
import '../theme/light_colors.dart' as light;
import '../theme/dark_colors.dart' as dark;

class History extends StatefulWidget {
  final bool isDark;
  const History({super.key, required this.isDark});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String _selectedFilter = 'all'; // 'all', 'income', 'expense'
  String _sortType = 'date_desc'; // 'date_desc', 'date_asc', 'amount_desc', 'amount_asc'

  // Category Icons Mapping Helper
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Makanan':
        return Icons.restaurant;
      case 'Transportasi':
        return Icons.directions_car;
      case 'Hiburan':
        return Icons.movie;
      case 'Belanja':
        return Icons.shopping_bag;
      case 'Tagihan':
        return Icons.receipt;
      case 'Gaji':
        return Icons.work;
      case 'Freelance':
        return Icons.laptop;
      case 'Bisnis':
        return Icons.store;
      case 'Hibah':
        return Icons.card_giftcard;
      case 'Investasi':
        return Icons.trending_up;
      default:
        return Icons.more_horiz;
    }
  }

  // Group and sort transactions dynamically
  List<dynamic> _processTransactions(List<Map<String, dynamic>> rawList) {
    // 1. Apply active filter (Semua, Pemasukan, Pengeluaran)
    List<Map<String, dynamic>> filteredList = rawList.where((tx) {
      if (_selectedFilter == 'income') return tx['type'] == 'income';
      if (_selectedFilter == 'expense') return tx['type'] == 'expense';
      return true;
    }).toList();

    // 2. Apply active sort type
    if (_sortType == 'date_desc') {
      filteredList.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    } else if (_sortType == 'date_asc') {
      filteredList.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
    } else if (_sortType == 'amount_desc') {
      filteredList.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
    } else if (_sortType == 'amount_asc') {
      filteredList.sort((a, b) => (a['amount'] as double).compareTo(b['amount'] as double));
    }

    // 3. Group by Month and Year (e.g. "Mei 2026")
    Map<String, List<Map<String, dynamic>>> grouped = {};
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    for (var tx in filteredList) {
      final date = DateTime.parse(tx['date']);
      final key = "${months[date.month - 1]} ${date.year}";
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(tx);
    }

    // 4. Flatten grouped map into lists with section header strings
    List<dynamic> flatList = [];
    grouped.forEach((header, items) {
      flatList.add(header); // section header string
      flatList.addAll(items); // transaction map items
    });

    return flatList;
  }

  void _showSortSheet(BuildContext context, dynamic colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Urutkan Riwayat',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.calendar_today, color: _sortType == 'date_desc' ? colors.blue : colors.textSecondary),
                title: Text(
                  'Terbaru (Tanggal Terbaru)',
                  style: TextStyle(
                    color: _sortType == 'date_desc' ? colors.blue : colors.textPrimary,
                    fontWeight: _sortType == 'date_desc' ? FontWeight.w600 : FontWeight.normal,
                    fontFamily: 'Inter',
                  ),
                ),
                trailing: _sortType == 'date_desc' ? Icon(Icons.check, color: colors.blue) : null,
                onTap: () {
                  setState(() => _sortType = 'date_desc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.history, color: _sortType == 'date_asc' ? colors.blue : colors.textSecondary),
                title: Text(
                  'Terlama (Tanggal Terlama)',
                  style: TextStyle(
                    color: _sortType == 'date_asc' ? colors.blue : colors.textPrimary,
                    fontWeight: _sortType == 'date_asc' ? FontWeight.w600 : FontWeight.normal,
                    fontFamily: 'Inter',
                  ),
                ),
                trailing: _sortType == 'date_asc' ? Icon(Icons.check, color: colors.blue) : null,
                onTap: () {
                  setState(() => _sortType = 'date_asc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.trending_up, color: _sortType == 'amount_desc' ? colors.blue : colors.textSecondary),
                title: Text(
                  'Nominal Tertinggi',
                  style: TextStyle(
                    color: _sortType == 'amount_desc' ? colors.blue : colors.textPrimary,
                    fontWeight: _sortType == 'amount_desc' ? FontWeight.w600 : FontWeight.normal,
                    fontFamily: 'Inter',
                  ),
                ),
                trailing: _sortType == 'amount_desc' ? Icon(Icons.check, color: colors.blue) : null,
                onTap: () {
                  setState(() => _sortType = 'amount_desc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.trending_down, color: _sortType == 'amount_asc' ? colors.blue : colors.textSecondary),
                title: Text(
                  'Nominal Terendah',
                  style: TextStyle(
                    color: _sortType == 'amount_asc' ? colors.blue : colors.textPrimary,
                    fontWeight: _sortType == 'amount_asc' ? FontWeight.w600 : FontWeight.normal,
                    fontFamily: 'Inter',
                  ),
                ),
                trailing: _sortType == 'amount_asc' ? Icon(Icons.check, color: colors.blue) : null,
                onTap: () {
                  setState(() => _sortType = 'amount_asc');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.isDark ? dark.darkColors : light.lightColors;
    final l10n = AppLocalizations.of(context)!;

    final pageBgColor = widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBgColor = widget.isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final filterBgColor = widget.isDark ? const Color(0xFF1E2638) : const Color(0xFFE2E8F0);
    final textCyan = const Color(0xFF00AED6);

    final numberFormatter = NumberFormat.decimalPattern('id');
    const shortMonths = [
      'Mei', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ]; // Using standard index logic where date.month represents the month

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        title: Text(
          l10n.riwayat,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: pageBgColor,
        elevation: 0,
        foregroundColor: colors.textPrimary,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
            tooltip: 'Pengaturan',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Horizontal Scrolling Row
          Container(
            height: 42,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // 1. Semua Pill
                        GestureDetector(
                          onTap: () => setState(() => _selectedFilter = 'all'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedFilter == 'all' ? textCyan : filterBgColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.grid_view_rounded,
                                  size: 16,
                                  color: _selectedFilter == 'all' ? Colors.white : colors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.semua,
                                  style: TextStyle(
                                    color: _selectedFilter == 'all' ? Colors.white : colors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 2. Pemasukan Pill
                        GestureDetector(
                          onTap: () => setState(() => _selectedFilter = 'income'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedFilter == 'income' ? textCyan : filterBgColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 16,
                                  color: _selectedFilter == 'income'
                                      ? Colors.white
                                      : const Color(0xFF22C55E),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.pemasukan,
                                  style: TextStyle(
                                    color: _selectedFilter == 'income' ? Colors.white : colors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 3. Pengeluaran Pill
                        GestureDetector(
                          onTap: () => setState(() => _selectedFilter = 'expense'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedFilter == 'expense' ? textCyan : filterBgColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 16,
                                  color: _selectedFilter == 'expense'
                                      ? Colors.white
                                      : const Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.pengeluaran,
                                  style: TextStyle(
                                    color: _selectedFilter == 'expense' ? Colors.white : colors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 4. Sort Button (Far Right, Fixed Position)
                GestureDetector(
                  onTap: () => _showSortSheet(context, colors),
                  child: Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: filterBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Live Database List Builder
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DBHelper.getTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: colors.textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada riwayat transaksi.',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final flatList = _processTransactions(snapshot.data!);

                if (flatList.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada transaksi yang cocok.',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 160), // bottom margin padding for floating navbar
                  itemCount: flatList.length,
                  itemBuilder: (context, index) {
                    final item = flatList[index];

                    if (item is String) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 10, left: 4),
                        child: Text(
                          item,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      );
                    }

                    // Render Transaction Card Item
                    final tx = item as Map<String, dynamic>;
                    final isInc = tx['type'] == 'income';
                    final date = DateTime.parse(tx['date']);

                    return Container(
                      height: 84,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.isDark
                              ? Colors.white.withOpacity(0.04)
                              : Colors.black.withOpacity(0.04),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left Compact Date Badge
                          SizedBox(
                            width: 58,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  date.day.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${shortMonths[date.month]} ${date.year}",
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Vertical Line Divider
                          Container(
                            width: 1.5,
                            height: 44,
                            color: widget.isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.06),
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                          ),

                          // Middle Title Block
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx['category'],
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isInc ? l10n.pemasukan : l10n.pengeluaran,
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Right Side Category Icon & Dynamic Price Tag
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: (isInc ? colors.green : colors.red).withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getCategoryIcon(tx['category']),
                                  color: isInc ? colors.green : colors.red,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${isInc ? '+' : '-'} Rp. ${numberFormatter.format(tx['amount'])}",
                                style: TextStyle(
                                  color: isInc ? colors.green : colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}