package com.ayushprtp.pikanda

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen / lockscreen widget showing real-time distance to the nearest
 * group member. Data is written from Dart via the home_widget package under the
 * keys "distances" (newline-separated "Name — 2.3 km away" lines).
 */
class DistanceWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.distance_widget)
            val distances = widgetData.getString("distances", null)
            if (distances.isNullOrBlank()) {
                views.setTextViewText(R.id.widget_title, "Pikanda 🐼⚡")
                views.setTextViewText(
                    R.id.widget_body,
                    "Open the app and turn on live location"
                )
            } else {
                val lines = distances.split("\n")
                views.setTextViewText(R.id.widget_title, "📍 Distance")
                views.setTextViewText(R.id.widget_body, lines.joinToString("\n"))
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
