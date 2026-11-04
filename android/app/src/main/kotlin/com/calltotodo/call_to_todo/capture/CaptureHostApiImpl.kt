package com.calltotodo.call_to_todo.capture

import android.Manifest
import android.app.Activity
import android.app.NotificationManager
import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.calltotodo.call_to_todo.CaptureConfig
import com.calltotodo.call_to_todo.CaptureHostApi
import com.calltotodo.call_to_todo.CaptureStatus
import kotlin.coroutines.resume
import kotlinx.coroutines.suspendCancellableCoroutine

/**
 * [CaptureHostApi] 구현. UI 엔진(액티비티 있음)과 백그라운드 엔진(액티비티 없음) 양쪽에서 쓴다.
 * 권한 요청처럼 액티비티가 필요한 호출은 백그라운드에서 false 를 돌려준다.
 */
class CaptureHostApiImpl(
    private val context: Context,
    private val activity: Activity?,
    private val onDartReady: () -> Unit = {},
) : CaptureHostApi {

    private val appContext = context.applicationContext
    private val prefs = CapturePrefs(appContext)
    private var pendingPermission: ((Boolean) -> Unit)? = null

    override fun getStatus(): CaptureStatus = CaptureStatus(
        notificationListenerEnabled = isNotificationListenerEnabled(appContext),
        smsPermissionGranted = hasSmsPermission(appContext),
        ignoringBatteryOptimizations = isIgnoringBatteryOptimizations(appContext),
        serviceRunning = CaptureForegroundService.isRunning,
    )

    override fun setCaptureConfig(config: CaptureConfig) {
        prefs.apply(config)
        if (config.captureEnabled) {
            CaptureForegroundService.start(appContext)
            SmsCaptureController.sync(appContext)
        } else {
            CaptureForegroundService.stop(appContext)
            SmsCaptureController.unregister(appContext)
        }
    }

    override fun openNotificationListenerSettings() {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivitySafely(intent)
    }

    override fun openBatteryOptimizationSettings() {
        if (isIgnoringBatteryOptimizations(appContext)) return
        // 직접 요청 대화상자(REQUEST_IGNORE_BATTERY_OPTIMIZATIONS 필요). 실패하면 설정 목록으로.
        val direct = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
            .setData(Uri.parse("package:${appContext.packageName}"))
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (!startActivitySafely(direct)) {
            startActivitySafely(
                Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
        }
    }

    override suspend fun requestSmsPermission(): Boolean {
        if (hasSmsPermission(appContext)) return true
        val host = activity ?: return false
        return suspendCancellableCoroutine { continuation ->
            pendingPermission?.invoke(false)
            pendingPermission = { granted ->
                pendingPermission = null
                if (continuation.isActive) continuation.resume(granted)
            }
            ActivityCompat.requestPermissions(host, arrayOf(Manifest.permission.READ_SMS), PERMISSION_REQUEST_CODE)
        }
    }

    /** MainActivity.onRequestPermissionsResult 에서 호출. 처리했으면 true. */
    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != PERMISSION_REQUEST_CODE) return false
        val granted = grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        if (granted) SmsCaptureController.sync(appContext)
        pendingPermission?.invoke(granted)
        return true
    }

    override fun signalDartReady() = onDartReady()

    private fun startActivitySafely(intent: Intent): Boolean = try {
        (activity ?: appContext).startActivity(intent)
        true
    } catch (_: ActivityNotFoundException) {
        false
    } catch (_: SecurityException) {
        false
    }

    companion object {
        private const val PERMISSION_REQUEST_CODE = 0x535

        fun hasSmsPermission(context: Context): Boolean =
            ContextCompat.checkSelfPermission(context, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED

        fun isNotificationListenerEnabled(context: Context): Boolean {
            val component = ComponentName(context, CaptureNotificationListenerService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                return nm.isNotificationListenerAccessGranted(component)
            }
            return (Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners") ?: "")
                .split(':')
                .mapNotNull { ComponentName.unflattenFromString(it) }
                .contains(component)
        }

        fun isIgnoringBatteryOptimizations(context: Context): Boolean {
            val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            return pm.isIgnoringBatteryOptimizations(context.packageName)
        }
    }
}
