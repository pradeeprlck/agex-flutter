package com.agex.flutter.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import com.agex.flutter.R

/**
 * AgriExpert Voice Assistant Home Screen Widget.
 *
 * Displays a compact card with:
 * - App branding
 * - Quick voice ask button (deep links to app with voice mode)
 * - Weather summary placeholder
 *
 * Copy this file to:
 *   android/app/src/main/kotlin/com/agex/flutter/widget/AgexWidgetProvider.kt
 *
 * Also add the widget layout XML and widget info XML (see companion files).
 */
class AgexWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.agex_widget)

            // Voice button deep link -> opens app in voice assistant mode
            val voiceIntent = Intent(Intent.ACTION_VIEW, Uri.parse("agex://voice"))
            voiceIntent.setPackage(context.packageName)
            val voicePendingIntent = PendingIntent.getActivity(
                context, 0, voiceIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.btn_voice, voicePendingIntent)

            // Open app on widget tap
            val openIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (openIntent != null) {
                val openPendingIntent = PendingIntent.getActivity(
                    context, 1, openIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, openPendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
