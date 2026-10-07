package com.example.weather_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class WeatherWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            val location = widgetData.getString("widget_location", "Location")
            val temp = widgetData.getString("widget_temperature", "--")
            val desc = widgetData.getString("widget_description", "Loading...")

            views.setTextViewText(R.id.tv_location, location)
            views.setTextViewText(R.id.tv_temperature, temp)
            views.setTextViewText(R.id.tv_description, desc)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
