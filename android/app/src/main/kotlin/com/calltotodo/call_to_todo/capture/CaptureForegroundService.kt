package com.calltotodo.call_to_todo.capture

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import com.calltotodo.call_to_todo.MainActivity
import com.calltotodo.call_to_todo.R

/**
 * 수집기를 살려 두는 `dataSync` 타입 Foreground Service.
 *
 * 하는 일은 작다: 낮은 중요도의 상시 알림을 띄워 프로세스 우선순위를 올리고, SMS 옵저버 등록을
 * 보장한다. 알림 리스너 자체는 시스템이 바인딩해서 유지하므로 이 서비스가 없어도 동작하지만,
 * 저사양 기기에서 프로세스가 자주 죽는 것을 줄여 준다.
 *
 * Android 15(API 35) 는 dataSync 서비스를 24시간 중 최대 6시간만 허용하고 [onTimeout] 으로 끝낸다.
 * 그 뒤에도 알림 리스너·SMS 옵저버는 프로세스가 살아 있는 한 계속 동작하며, 앱을 다시 열면 재시작된다.
 */
class CaptureForegroundService : Service() {

    override fun onCreate() {
        super.onCreate()
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopSelf()
            return START_NOT_STICKY
        }
        ServiceCompat.startForeground(
            this,
            NOTIFICATION_ID,
            buildNotification(),
            ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC,
        )
        isRunning = true
        SmsCaptureController.sync(this)
        return START_STICKY
    }

    override fun onTimeout(startId: Int, fgsType: Int) {
        Log.w(TAG, "dataSync time budget exhausted; stopping foreground service (listeners stay alive)")
        stopSelf()
    }

    override fun onDestroy() {
        isRunning = false
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createChannel() {
        val channel = NotificationChannel(CHANNEL_ID, "수집 서비스", NotificationManager.IMPORTANCE_MIN).apply {
            description = "메신저 알림·SMS 에서 일정을 찾는 동안 표시되는 상시 알림"
            setShowBadge(false)
        }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    private fun buildNotification(): Notification {
        val openApp = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("일정 수집 중")
            .setContentText("메신저 알림과 문자에서 일정을 찾고 있습니다. 텍스트는 기기 안에서만 처리됩니다.")
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setOngoing(true)
            .setSilent(true)
            .setContentIntent(openApp)
            .build()
    }

    companion object {
        private const val TAG = "CaptureService"
        private const val CHANNEL_ID = "capture_service"
        private const val NOTIFICATION_ID = 0xCA9
        private const val ACTION_STOP = "com.calltotodo.call_to_todo.capture.STOP"

        @Volatile
        var isRunning: Boolean = false
            private set

        /** 시작을 시도한다. 백그라운드 제한으로 거부되면 false (수집기는 서비스 없이도 동작). */
        fun start(context: Context): Boolean {
            val intent = Intent(context, CaptureForegroundService::class.java)
            return try {
                ContextCompat.startForegroundService(context, intent)
                true
            } catch (e: Exception) {
                // Android 12+ ForegroundServiceStartNotAllowedException 포함: 백그라운드/부팅 직후 시작 제한.
                Log.w(TAG, "foreground service start failed", e)
                false
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, CaptureForegroundService::class.java))
        }
    }
}
