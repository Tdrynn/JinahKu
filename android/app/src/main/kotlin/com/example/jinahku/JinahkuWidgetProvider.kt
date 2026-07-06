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
                saveWidgetData(...)
                val balance = widgetData.getString("balance", "Rp 0")
                val updatedAt = widgetData.getString("updated_at", "")
                val isNegative = widgetData.getBoolean("balance_negative", false)

                setTextViewText(R.id.widget_balance, balance)
                setTextViewText(R.id.widget_updated_at, updatedAt)

                val balanceColor = if (isNegative) Color.parseColor("#DC2626")
                                    else Color.parseColor("#0F172A")
                setTextColor(R.id.widget_balance, balanceColor)

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