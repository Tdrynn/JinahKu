// !!! GANTI baris package di bawah ini sesuai applicationId project kamu !!!
// Cek di android/app/build.gradle (atau build.gradle.kts) -> defaultConfig.applicationId
// Contoh: kalau applicationId = "com.contoh.jinahku", maka:
// package com.contoh.jinahku
package com.example.jinahku

import android.appwidget.AppWidgetManager
import android.content.Context
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class JinahkuWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.jinahku_widget).apply {
                // Key-key ini harus SAMA PERSIS dengan key yang dipakai di
                // sisi Dart lewat HomeWidget.saveWidgetData(...)
                val balance = widgetData.getString("balance", "Rp 0")
                val updatedAt = widgetData.getString("updated_at", "")
                val isNegative = widgetData.getBoolean("balance_negative", false)

                setTextViewText(R.id.widget_balance, balance)
                setTextViewText(R.id.widget_updated_at, updatedAt)

                // Merah kalau saldo minus, biru gelap kalau normal --
                // sedikit sentuhan supaya widget terasa "hidup" & informatif.
                val balanceColor = if (isNegative) Color.parseColor("#DC2626")
                                    else Color.parseColor("#0F172A")
                setTextColor(R.id.widget_balance, balanceColor)

                // Tap di mana saja pada widget -> buka aplikasi
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}