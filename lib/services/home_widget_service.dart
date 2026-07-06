import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

class HomeWidgetService {
  HomeWidgetService._();

  static const String _androidWidgetName = 'JinahkuWidgetProvider';

  static Future<void> updateBalanceWidget(double balance) async {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    try {
      await HomeWidget.saveWidgetData<String>(
        'balance',
        formatter.format(balance),
      );
      await HomeWidget.saveWidgetData<String>(
        'updated_at',
        'Diperbarui ${DateFormat('HH:mm', 'id').format(DateTime.now())}',
      );
      await HomeWidget.saveWidgetData<bool>(
        'balance_negative',
        balance < 0,
      );

      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
      );
    } catch (e) {
      print('HomeWidgetService update failed: $e');
    }
  }
}