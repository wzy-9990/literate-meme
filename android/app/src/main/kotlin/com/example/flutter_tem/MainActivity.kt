package com.pinkala.driver

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.pinkala.driver/app_icon"

    // 图标名称到 Activity Alias 的映射
    private val iconMap = mapOf(
        "spring_festival" to "com.pinkala.driver.spring_festival",
        "labor_day" to "com.pinkala.driver.labor_day",
        "national_day" to "com.pinkala.driver.national_day",
        "christmas" to "com.pinkala.driver.christmas"
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "changeIcon" -> {
                    val iconName = call.argument<String>("iconName")
                    if (iconName != null) {
                        changeAppIcon(iconName, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Icon name is required", null)
                    }
                }
                "getCurrentIcon" -> {
                    val currentIcon = getCurrentAppIcon()
                    result.success(currentIcon)
                }
                "isSupported" -> {
                    result.success(true) // Android 8.0+ 都支持
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun changeAppIcon(iconName: String, result: MethodChannel.Result) {
        try {
            val packageManager = packageManager
            val packageName = packageName

            // 禁用所有图标别名
            iconMap.values.forEach { aliasName ->
                packageManager.setComponentEnabledSetting(
                    ComponentName(packageName, aliasName),
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                )
            }

            // 如果不是默认图标，启用对应的图标别名
            if (iconName != "default") {
                val aliasName = iconMap[iconName]
                if (aliasName != null) {
                    packageManager.setComponentEnabledSetting(
                        ComponentName(packageName, aliasName),
                        PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                        PackageManager.DONT_KILL_APP
                    )
                    result.success(true)
                } else {
                    result.error("INVALID_ICON", "Unknown icon name: $iconName", null)
                }
            } else {
                // 默认图标，所有别名都禁用即可
                result.success(true)
            }
        } catch (e: Exception) {
            result.error("CHANGE_ICON_FAILED", e.message, null)
        }
    }

    private fun getCurrentAppIcon(): String {
        try {
            val packageManager = packageManager
            val packageName = packageName

            // 检查哪个图标别名是启用的
            iconMap.forEach { (iconName, aliasName) ->
                val state = packageManager.getComponentEnabledSetting(
                    ComponentName(packageName, aliasName)
                )
                if (state == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) {
                    return iconName
                }
            }

            // 如果没有启用的别名，返回默认图标
            return "default"
        } catch (e: Exception) {
            return "default"
        }
    }
}
