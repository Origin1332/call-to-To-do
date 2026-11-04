package com.calltotodo.call_to_todo.capture

import android.content.Context
import android.content.SharedPreferences
import com.calltotodo.call_to_todo.CaptureConfig

/**
 * Dart 설정 저장소(drift)의 사본. 네이티브 수집기는 Dart 엔진이 떠 있지 않아도
 * (부팅 직후, 알림 수신 시) 허용 앱·on/off 를 알아야 하므로 SharedPreferences 에 둔다.
 */
class CapturePrefs(context: Context) {

    private val prefs: SharedPreferences =
        context.applicationContext.getSharedPreferences(FILE, Context.MODE_PRIVATE)

    var captureEnabled: Boolean
        get() = prefs.getBoolean(KEY_CAPTURE_ENABLED, false)
        private set(value) = prefs.edit().putBoolean(KEY_CAPTURE_ENABLED, value).apply()

    var notificationsEnabled: Boolean
        get() = prefs.getBoolean(KEY_NOTIFICATIONS_ENABLED, true)
        private set(value) = prefs.edit().putBoolean(KEY_NOTIFICATIONS_ENABLED, value).apply()

    var smsEnabled: Boolean
        get() = prefs.getBoolean(KEY_SMS_ENABLED, true)
        private set(value) = prefs.edit().putBoolean(KEY_SMS_ENABLED, value).apply()

    var allowedPackages: Set<String>
        get() = prefs.getStringSet(KEY_ALLOWED_PACKAGES, null) ?: DEFAULT_ALLOWED_PACKAGES
        private set(value) = prefs.edit().putStringSet(KEY_ALLOWED_PACKAGES, value).apply()

    /** 마지막으로 처리한 SMS `_id`. 처음 등록할 때 현재 최대값으로 맞춰 과거 문자를 건너뛴다. */
    var lastSmsId: Long
        get() = prefs.getLong(KEY_LAST_SMS_ID, -1L)
        set(value) = prefs.edit().putLong(KEY_LAST_SMS_ID, value).apply()

    fun apply(config: CaptureConfig) {
        captureEnabled = config.captureEnabled
        notificationsEnabled = config.notificationsEnabled
        smsEnabled = config.smsEnabled
        allowedPackages = config.allowedPackages.map { it.trim() }.filter { it.isNotEmpty() }.toSet()
    }

    fun isPackageAllowed(packageName: String): Boolean = allowedPackages.contains(packageName)

    companion object {
        private const val FILE = "capture_prefs"
        private const val KEY_CAPTURE_ENABLED = "capture_enabled"
        private const val KEY_NOTIFICATIONS_ENABLED = "notifications_enabled"
        private const val KEY_SMS_ENABLED = "sms_enabled"
        private const val KEY_ALLOWED_PACKAGES = "allowed_packages"
        private const val KEY_LAST_SMS_ID = "last_sms_id"

        /** Dart 쪽 `CaptureSources.defaultAllowedPackages` 와 같은 목록. */
        val DEFAULT_ALLOWED_PACKAGES: Set<String> = setOf(
            "com.kakao.talk",
            "com.google.android.apps.messaging",
            "com.samsung.android.messaging",
            "com.skt.prod.dialer",
            "com.android.dialer",
            "com.samsung.android.dialer",
        )
    }
}
