package com.ayushprtp.pikanda

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget showing the group pet: emoji, name, mood line and a
 * compact stats row. Fed from Dart via home_widget under pet_* keys.
 */
class PetWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.pet_widget)
            val emoji = widgetData.getString("pet_emoji", "🥚")
            val name = widgetData.getString("pet_name", "No pet yet")
            val mood = widgetData.getString("pet_mood", "Adopt one in the app!")
            val stats = widgetData.getString("pet_stats", "")
            views.setTextViewText(R.id.pet_emoji, emoji)
            views.setTextViewText(R.id.pet_name, name)
            views.setTextViewText(R.id.pet_mood, mood)
            views.setTextViewText(R.id.pet_stats, stats)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
